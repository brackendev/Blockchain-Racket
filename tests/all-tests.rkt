#lang racket/base

(require rackunit
         "block-test.rkt"
         "blockchain-test.rkt"
         "demo-test.rkt"
         "demo-helper-test.rkt"
         "smart-contracts-test.rkt"
         "structs-test.rkt"
         "transaction-test.rkt"
         "transaction-io-test.rkt"
         "utils-test.rkt"
         "wallet-test.rkt")

(provide all-tests)

(define all-tests
  (test-suite
   "All tests"
   block-tests
   blockchain-tests
   demo-tests
   demo-helper-tests
   smart-contracts-tests
   structs-tests
   transaction-tests
   transaction-io-tests
   utils-tests
   wallet-tests))
