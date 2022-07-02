#lang racket/base

(require rackunit
         "../src/smart-contracts.rkt"
         "../src/transaction.rkt"
         "../src/wallet.rkt")

(provide smart-contracts-tests)

(module+ test
  (require rackunit/text-ui)
  (run-tests smart-contracts-tests))

(define wallet-a (make-wallet))

(define wallet-b (make-wallet))

(define tr1 (make-transaction #:from-wallet wallet-a
                              #:inputs '()
                              #:to-wallet wallet-b
                              #:value 123))

(define tr2 (process-transaction tr1))

(define smart-contracts-tests
  (test-suite
   "smart-contracts tests"

   ;; eval-contract

   (test-equal? "eval-contract"
                (eval-contract tr2 123)
                123)

   (test-equal? "eval-contract"
                (eval-contract tr2 "Hi")
                "Hi")

   (test-true "eval-contract"
              (eval-contract tr2 '()))

   (test-true "eval-contract"
              (eval-contract tr2 'true))

   (test-false "eval-contract"
               (eval-contract tr2 'false))

   (test-equal? "eval-contract"
                (eval-contract tr2 '(if #t "Hi" "Hey"))
                "Hi")

   (test-equal? "eval-contract"
                (eval-contract tr2 '(if #f "Hi" "Hey"))
                "Hey")

   (test-equal? "eval-contract"
                (eval-contract tr2 '(+ 1 2))
                3)

   ;; valid-transaction-contract?

   (test-false "valid-transaction-contract?"
               (valid-transaction? tr1))

   (test-true "valid-transaction-contract?"
              (valid-transaction? tr2))

   ))
