#lang racket/base

(require rackunit
         "../src/structs.rkt"
         "../src/transaction.rkt"
         "../src/wallet.rkt")

(provide transaction-tests)

(module+ test
  (require rackunit/text-ui)
  (run-tests transaction-tests))

(define wallet-a (make-wallet))

(define wallet-b (make-wallet))

(define tr (transaction wallet-a '() '() "616263" wallet-b 123))

(define make-tr (make-transaction #:from-wallet wallet-a
                                  #:inputs '()
                                  #:to-wallet wallet-b
                                  #:value 123))

(define processed-tr (process-transaction make-tr))

(define transaction-tests
  (test-suite
   "transaction-tests tests"

   ;; make-transaction

   (test-not-false "make-transaction transaction-from"
                   (and (wallet-private-key (transaction-from make-tr))
                        (wallet-public-key (transaction-from make-tr))))

   (test-equal? "make-transaction transaction-inputs"
                (transaction-inputs make-tr)
                '())

   (test-not-false "make-transaction transaction-to"
                   (and (wallet-private-key (transaction-to make-tr))
                        (wallet-public-key (transaction-to make-tr))))

   (test-equal? "make-transaction transaction-value"
                (transaction-value make-tr)
                123)

   ;; process-transaction

   (test-not-false "process-transaction transaction-from"
                   (and (wallet-private-key (transaction-from processed-tr))
                        (wallet-public-key (transaction-from processed-tr))))

   (test-equal? "process-transaction transaction-inputs"
                (transaction-inputs processed-tr)
                '())

   (test-equal? "process-transaction transaction-outputs"
                (length (transaction-outputs processed-tr))
                2)

   (test-not-false "process-transaction transaction-signature"
                   (transaction-signature processed-tr))

   (test-not-false "process-transaction transaction to"
                   (and (wallet-private-key (transaction-to processed-tr))
                        (wallet-public-key (transaction-to processed-tr))))

   (test-equal? "process-transaction transaction-value"
                (transaction-value processed-tr)
                123)

   ;; sign-transaction

   (test-not-false "sign-transaction"
                   (sign-transaction #:from-wallet wallet-a
                                     #:to-wallet wallet-b
                                     #:value 123))

   ;; valid-transaction-signature?

   (test-true "valid-transaction-signature?"
              (valid-transaction-signature? processed-tr))

   ;; valid-transaction?

   (test-true "valid-transaction?"
              (valid-transaction? processed-tr))))
