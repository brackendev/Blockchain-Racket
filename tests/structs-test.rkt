#lang racket/base

(require rackunit
         "../src/structs.rkt"
         "../src/transaction.rkt"
         "../src/transaction-io.rkt"
         "../src/wallet.rkt")

(provide structs-tests)

(module+ test
  (require rackunit/text-ui)
  (run-tests structs-tests))

(define wallet-a (make-wallet))
(define wallet-b (make-wallet))
(define tr (transaction wallet-a '() '() "616263" wallet-b 123))
(define bl (block "616263" 1 "646566" 321 tr))
(define utxo-a (transaction-io "owner" 321 "616263" 123))
(define hash (calculate-transaction-io-hash #:value 123
                                            #:owner-wallet "owner"
                                            #:timestamp 123))
(define utxo-b (make-transaction-io #:value 123 #:owner-wallet "owner"))

(define structs-tests
  (test-suite
   "structs tests"

   ;; block

   (test-equal? "block-current-hash"
                (block-current-hash bl)
                "616263")

   (test-equal? "block-nonce"
                (block-nonce bl)
                1)

   (test-equal? "block-previous-hash"
                (block-previous-hash bl)
                "646566")

   (test-equal? "block-timestamp"
                (block-timestamp bl)
                321)

   (test-not-false "block-transaction"
                   (block-transaction bl))

   ;; TODO: blockchain

   ;; TODO: peer-info

   ;; TODO: peer-info-io

   ;; TODO: peer-context-data

   ;; transaction

   (test-not-false "transaction-from"
                   (and (wallet-private-key (transaction-from tr))
                        (wallet-public-key (transaction-from tr))))

   (test-equal? "transaction-inputs"
                (transaction-inputs tr)
                '())

   (test-equal? "transaction-outputs"
                (transaction-outputs tr)
                '())

   (test-equal? "transaction-signature"
                (transaction-signature tr)
                "616263")

   (test-not-false "transaction-to"
                   (and (wallet-private-key (transaction-to tr))
                        (wallet-public-key (transaction-to tr))))

   (test-equal? "transaction value"
                (transaction-value tr)
                123)

   ;; transaction-io

   (test-equal? "transaction-io-owner"
                (transaction-io-owner utxo-a)
                "owner")

   (test-equal? "transaction-io-timestamp"
                (transaction-io-timestamp utxo-a)
                321)

   (test-equal? "transaction-io-transaction-hash"
                (transaction-io-transaction-hash utxo-a)
                "616263")

   (test-equal? "transaction-io-value"
                (transaction-io-value utxo-a)
                123)

   ;; wallet

   (test-not-false "wallet-private-key"
                   (wallet-private-key wallet-a))

   (test-not-false "wallet-public-key"
                   (wallet-public-key wallet-b))))
