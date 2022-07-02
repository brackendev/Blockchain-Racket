#lang racket

(require crypto
         crypto/all
         "structs.rkt")

(provide make-wallet)

;; Generate a wallet from random public and private keys with the RSA algorithm.
(define (make-wallet)
  (letrec ([rsa-impl (get-pk 'rsa libcrypto-factory)]
           [privkey (generate-private-key rsa-impl '((nbits 512)))]
           [pubkey (pk-key->public-only-key privkey)])
    (wallet (bytes->hex-string (pk-key->datum privkey 'PrivateKeyInfo))
            (bytes->hex-string (pk-key->datum pubkey 'SubjectPublicKeyInfo)))))
