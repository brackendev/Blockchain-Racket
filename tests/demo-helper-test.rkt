#lang racket/base

(require rackunit
         "../src/demo-helper.rkt")

(provide demo-helper-tests)

(module+ test
  (require rackunit/text-ui)
  (run-tests demo-helper-tests))

(define demo-helper-tests
  (test-suite
   "demo-helper tests"))

;; TODO: format-transaction

;; TODO: print-block

;; TODO: print-blockchain

;; TODO: print-wallets
