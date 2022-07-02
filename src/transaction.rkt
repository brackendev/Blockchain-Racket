#lang racket

(require crypto
         crypto/all
         (only-in file/sha1 hex-string->bytes)
         racket/serialize
         "structs.rkt"
         "transaction-io.rkt"
         "utils.rkt")

(provide make-transaction
         process-transaction
         sign-transaction
         valid-transaction?
         valid-transaction-signature?)

;; Use all crypto factories.
(use-all-factories!)

;; Makes an empty, unsigned, and unprocessed (no input outputs) transaction.
;; Used to send money and create the first (genesis) transaction.
(define (make-transaction #:from-wallet from
                          #:inputs inputs
                          #:to-wallet to
                          #:value value)
  (transaction from inputs '() "" to value))

;; Create a transaction hash.
(define (sign-transaction #:from-wallet from
                          #:to-wallet to
                          #:value value)
  (let ([privkey (wallet-private-key from)]
        [pubkey (wallet-public-key from)])
    (bytes->hex-string
     (digest/sign
      (datum->pk-key (hex-string->bytes privkey) 'PrivateKeyInfo)
      'sha1
      (bytes-append
       (string->bytes/utf-8 (~a (serialize from)))
       (string->bytes/utf-8 (~a (serialize to)))
       (string->bytes/utf-8 (number->string value)))))))

;; Based on transaction inputs, create transaction outputs that contain the transaction's value and leftover money.
(define (process-transaction tr)
  (letrec
      ([inputs (transaction-inputs tr)]
       [outputs (transaction-outputs tr)]
       [value (transaction-value tr)]
       [inputs-sum (foldr + 0 (map (λ (i) (transaction-io-value i)) inputs))]
       [leftover (- inputs-sum value)]
       [new-outputs (list
                     (make-transaction-io #:owner-wallet (transaction-to tr)
                                          #:value value)
                     (make-transaction-io #:owner-wallet (transaction-from tr)
                                          #:value leftover))])
    (transaction (transaction-from tr)
                 inputs
                 (append new-outputs outputs)
                 (sign-transaction #:from-wallet (transaction-from tr)
                                   #:to-wallet (transaction-to tr)
                                   #:value (transaction-value tr))
                 (transaction-to tr)
                 value)))

;; Check a transaction signature.
(define (valid-transaction-signature? tr)
  (let ([pubkey (wallet-public-key (transaction-from tr))])
    (digest/verify
     (datum->pk-key (hex-string->bytes pubkey) 'SubjectPublicKeyInfo)
     'sha1
     (bytes-append
      (string->bytes/utf-8 (~a (serialize (transaction-from tr))))
      (string->bytes/utf-8 (~a (serialize (transaction-to tr))))
      (string->bytes/utf-8 (number->string (transaction-value tr))))
     (hex-string->bytes (transaction-signature tr)))))

;; Determine transaction validity:
;; valid-transaction-signature? checks if its signature is valid.
;; valid-transaction-io? checks if all outputs are valid.
;; The sum of the inputs is greater than or equal to the sum of the outputs. (No double spending.)
(define (valid-transaction? tr)
  (let ([sum-inputs (foldr + 0 (map (λ (tr) (transaction-io-value tr))
                                    (transaction-inputs tr)))]
        [sum-outputs (foldr + 0 (map (λ (tr) (transaction-io-value tr))
                                     (transaction-outputs tr)))])
    (and (valid-transaction-signature? tr)
         (true-for-all? valid-transaction-io? (transaction-outputs tr))
         (>= sum-inputs sum-outputs))))
