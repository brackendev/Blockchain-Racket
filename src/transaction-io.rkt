#lang racket

(require (only-in sha sha256)
         (only-in sha bytes->hex-string)
         racket/serialize
         threading
         "structs.rkt")

(provide (struct-out transaction-io)
         calculate-transaction-io-hash
         make-transaction-io
         valid-transaction-io?)

;; Create a transaction-io hash.
(define (calculate-transaction-io-hash #:owner-wallet owner
                                       #:timestamp timestamp
                                       #:value value)
  (~> (bytes-append
       (string->bytes/utf-8 (number->string value))
       (string->bytes/utf-8 (~a (serialize owner)))
       (string->bytes/utf-8 (number->string timestamp)))
      (sha256)
      (bytes->hex-string)))

;; Helper to create a transaction-io hash.
(define (make-transaction-io #:owner-wallet owner #:value value)
  (let ([timestamp (current-milliseconds)])
    (transaction-io owner
                    timestamp
                    (calculate-transaction-io-hash #:owner-wallet owner
                                                   #:timestamp timestamp
                                                   #:value value)
                    value)))

;; Validate a transaction-io's hash against the hash of the value, owner, and timestamp.
(define (valid-transaction-io? t-in)
  (equal? (transaction-io-transaction-hash t-in)
          (calculate-transaction-io-hash
           #:owner-wallet (transaction-io-owner t-in)
           #:timestamp (transaction-io-timestamp t-in)
           #:value (transaction-io-value t-in))))
