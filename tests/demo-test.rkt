#lang racket/base

(require rackunit
         "../src/blockchain.rkt"
         "../src/structs.rkt"
         "../src/transaction.rkt"
         "../src/transaction-io.rkt"
         "../src/wallet.rkt")

(provide demo-tests)

(module+ test
  (require rackunit/text-ui)
  (demo-tests demo-tests))

(define coin-base (make-wallet))

(define wallet-a (make-wallet))

(define wallet-b (make-wallet))

(define genesis-tr (make-transaction #:from-wallet coin-base
                                     #:inputs '()
                                     #:to-wallet wallet-a
                                     #:value 100))

(define utxo (list (make-transaction-io #:owner-wallet wallet-a
                                        #:value 100)))

(define blockchain1 (init-blockchain #:genesis-tr genesis-tr
                                     #:seed-hash "616263"
                                     #:utxo utxo))

(define blockchain2 (send-money-blockchain #:blockchain blockchain1
                                           #:contract '()
                                           #:from-wallet wallet-a
                                           #:to-wallet wallet-b
                                           #:value 100))

(define blockchain3 (send-money-blockchain #:blockchain blockchain2
                                           #:contract '()
                                           #:from-wallet wallet-b
                                           #:to-wallet wallet-a
                                           #:value 100))

(define blockchain4 (send-money-blockchain #:blockchain blockchain3
                                           #:contract '()
                                           #:from-wallet wallet-b
                                           #:to-wallet wallet-a
                                           #:value 1000))

(define demo-tests
  (test-suite
   "demo tests"

   ;; blockchain1

   (test-equal? "blockchain1"
                (balance-wallet-blockchain blockchain1 wallet-a)
                100)

   (test-equal? "blockchain1"
                (balance-wallet-blockchain blockchain1 wallet-b)
                0)

   (test-equal? "blockchain-blocks blockchain1"
                (length (blockchain-blocks blockchain1))
                1)

   (test-equal? "blockchain-utxo blockchain1"
                (length (blockchain-utxo blockchain1))
                1)

   (test-true "valid-blockchain? blockchain1"
              (valid-blockchain? blockchain1))

   ;; blockchain2

   (test-equal? "blockchain2"
                (balance-wallet-blockchain blockchain2 wallet-a)
                50)

   (test-equal? "blockchain2"
                (balance-wallet-blockchain blockchain2 wallet-b)
                100)

   (test-equal? "blockchain-blocks blockchain2"
                (length (blockchain-blocks blockchain2))
                2)

   (test-equal? "blockchain-utxo blockchain2"
                (length (blockchain-utxo blockchain2))
                3)

   (test-true "valid-blockchain? blockchain2"
              (valid-blockchain? blockchain2))

   ;; blockchain3

   (test-equal? "blockchain3"
                (balance-wallet-blockchain blockchain3 wallet-a)
                150)

   (test-equal? "blockchain3"
                (balance-wallet-blockchain blockchain3 wallet-b)
                50)

   (test-equal? "blockchain-blocks blockchain3"
                (length (blockchain-blocks blockchain3))
                3)

   (test-equal? "blockchain-utxo blockchain3"
                (length (blockchain-utxo blockchain3))
                5)

   (test-true "valid-blockchain? blockchain3"
              (valid-blockchain? blockchain3))

   ;; blockchain4

   (test-equal? "blockchain4"
                (balance-wallet-blockchain blockchain4 wallet-a)
                150)

   (test-equal? "blockchain4"
                (balance-wallet-blockchain blockchain4 wallet-b)
                50)

   (test-equal? "blockchain-blocks blockchain4"
                (length (blockchain-blocks blockchain4))
                3)

   (test-equal? "blockchain-utxo blockchain4"
                (length (blockchain-utxo blockchain4))
                5)

   (test-true "valid-blockchain? blockchain4"
              (valid-blockchain? blockchain4))))
