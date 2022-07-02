#lang racket/base

(require rackunit
         "../src/transaction-io.rkt")

(provide transaction-io-tests)

(module+ test
  (require rackunit/text-ui)
  (run-tests transaction-io-tests))

(define utxo-a (transaction-io "owner" 321 "616263" 123))

(define hash (calculate-transaction-io-hash #:value 123
                                            #:owner-wallet "owner"
                                            #:timestamp 123))

(define utxo-b (make-transaction-io #:value 123 #:owner-wallet "owner"))

(define transaction-io-tests
  (test-suite
   "transaction-io tests"

   ;; calculate-transaction-io-hash

   (test-equal? "calculate-transaction-io-hash"
                hash
                "b4b4f410e327283092f292dc1b96e89a5779823d8c070560dfb39e45425f58f8")

   ;; make-transaction-io

   (test-equal? "make-transaction-io transaction-io-owner"
                (transaction-io-owner utxo-b)
                "owner")

   (test-equal? "make-transaction-io transaction-io-value"
                (transaction-io-value utxo-b)
                123)

   ;; valid-transaction-io?

   (test-false "valid-transaction-io? #f"
               (valid-transaction-io? utxo-a))

   (test-true "valid-transaction-io? #t"
              (valid-transaction-io? utxo-b))))
