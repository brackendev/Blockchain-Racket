#lang racket

(require "blockchain.rkt"
         "demo-helper.rkt"
         "structs.rkt"
         "transaction.rkt"
         "transaction-io.rkt"
         "utils.rkt"
         "wallet.rkt")

;;; ========== Start ==========

(when (file-exists? "blockchain.data")
  (begin
    (printf "Found 'blockchain.data', reading...\n")
    (print-blockchain (file->struct "blockchain.data"))
    (exit)))

(define coin-base (make-wallet))

(define wallet-a (make-wallet))

(define wallet-b (make-wallet))

;;; First (genesis) transaction and block

(printf "First (genesis) transaction\n")
(define genesis-tr (make-transaction #:from-wallet coin-base
                                     #:inputs '()
                                     #:to-wallet wallet-a
                                     #:value 100))
(define utxo (list (make-transaction-io #:owner-wallet wallet-a
                                        #:value 100)))

(printf "Mining first (genesis) block:\n")
(define blockchain (init-blockchain #:genesis-tr genesis-tr
                                    #:seed-hash "616263"
                                    #:utxo utxo))
(print-wallets blockchain wallet-a wallet-b)

;;; Second transaction

(printf "Mining second transaction:\n")
(set! blockchain (send-money-blockchain #:blockchain blockchain
                                        #:contract '()
                                        #:from-wallet wallet-a
                                        #:to-wallet wallet-b
                                        #:value 100))
(print-wallets blockchain wallet-a wallet-b)

;;; Third transaction

(printf "Mining third transaction:\n")
(set! blockchain (send-money-blockchain #:blockchain blockchain
                                        #:contract '()
                                        #:from-wallet wallet-b
                                        #:to-wallet wallet-a
                                        #:value 100))
(print-wallets blockchain wallet-a wallet-b)

;;; Fourth transaction

(printf "Mining fourth (not-valid) transaction:\n")
(set! blockchain (send-money-blockchain #:blockchain blockchain
                                        #:contract '()
                                        #:from-wallet wallet-b
                                        #:to-wallet wallet-a
                                        #:value 1000))
(print-wallets blockchain wallet-a wallet-b)

;; ========== End ==========

(printf "Blockchain is valid: ~a\n\n" (valid-blockchain? blockchain))

(for ([block (blockchain-blocks blockchain)])
  (print-block block)
  (newline))

(struct->file blockchain "blockchain.data")
(printf "Exported blockchain to 'blockchain.data'\n")
