#lang racket/base

(require rackunit
         "../src/blockchain.rkt"
         "../src/structs.rkt"
         "../src/transaction.rkt"
         "../src/transaction-io.rkt"
         "../src/wallet.rkt")

(provide blockchain-tests)

(module+ test
  (require rackunit/text-ui)
  (run-tests blockchain-tests))

(define wallet-a (make-wallet))

(define wallet-b (make-wallet))

(define genesis-tr (make-transaction #:from-wallet wallet-a
                                     #:inputs '()
                                     #:to-wallet wallet-b
                                     #:value 100))

(define utxo (list (make-transaction-io #:value 100
                                        #:owner-wallet wallet-b)))
                                        
(define bc (init-blockchain #:genesis-tr genesis-tr
                            #:seed-hash "616263"
                            #:utxo utxo))

(define blockchain-tests
  (test-suite
   "blockchain tests"

   ;; add-transaction-to-blockchain

   (test-equal? "add-transaction-to-blockchain"
                (length (blockchain-blocks (add-transaction-to-blockchain bc genesis-tr)))
                2)

   ;; balance-wallet-blockchain

   (test-equal? "balance-wallet-blockchain wallet-a"
                (balance-wallet-blockchain bc wallet-a)
                0)

   (test-equal? "balance-wallet-blockchain wallet-b"
                (balance-wallet-blockchain bc wallet-b)
                100)

   ;; init-blockchain

   (test-equal? "init-blockchain blockchain-blocks"
                (length (blockchain-blocks bc))
                1)

   (test-equal? "init-blockchain blockchain-utxo"
                (length (blockchain-utxo bc))
                1)

   ;; mining-reward-factor

   (test-equal? "mining-reward-factor"
                (mining-reward-factor (list bc))
                50)

   ;; receiver-transaction-inputs

   (test-equal? "receiver-transaction-inputs wallet-a utxo"
                (receiver-transaction-inputs wallet-a utxo)
                '())

   (test-success "receiver-transaction-inputs wallet-b utxo"
                 (receiver-transaction-inputs wallet-b utxo))

   ;; send-money-blockchain

   (test-equal? "send-money-blockchain wallet-a wallet-b"
                (length (blockchain-blocks (send-money-blockchain #:blockchain bc
                                                                  #:contract '()
                                                                  #:from-wallet wallet-a
                                                                  #:to-wallet wallet-b
                                                                  #:value 100)))
                1)

   (test-equal? "send-money-blockchain wallet-b wallet-a"
                (length (blockchain-blocks (send-money-blockchain #:blockchain bc
                                                                  #:contract '()
                                                                  #:from-wallet wallet-b
                                                                  #:to-wallet wallet-a
                                                                  #:value 100)))
                2)

   ;; valid-blockchain?

   (test-true "valid-blockchain?"
              (valid-blockchain? bc))))
