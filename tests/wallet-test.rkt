#lang racket/base

(require rackunit
         "../src/structs.rkt"
         "../src/wallet.rkt")

(provide wallet-tests)

(module+ test
  (require rackunit/text-ui)
  (run-tests wallet-tests))

(define w (make-wallet))

(define wallet-tests
  (test-suite
   "wallet tests"

   ;; make-wallet

   (test-not-false "wallet-private-key"
                   (wallet-private-key w))

   (test-not-false "wallet-public-key"
                   (wallet-public-key w))))
