#lang racket

(require "blockchain.rkt"
         "structs.rkt")

(provide format-transaction
         print-block
         print-blockchain
         print-wallets)

;; Convert a transaction object to a printable string.
(define (format-transaction tr)
  (format "...~a... sends ...~a... an amount of ~a."
          (substring (wallet-public-key (transaction-from tr)) 64 80)
          (substring (wallet-public-key (transaction-to tr)) 64 80)
          (transaction-value tr)))

;; Print details of a block.
(define (print-block bl)
  (printf "Block information\n=================
Hash:\t~a\nHash_p:\t~a\nStamp:\t~a\nNonce:\t~a\nData:\t~a\n"
          (block-current-hash bl)
          (block-previous-hash bl)
          (block-timestamp bl)
          (block-nonce bl)
          (format-transaction (block-transaction bl))))

;; Print the blockchain.
(define (print-blockchain bc)
  (for ([block (blockchain-blocks bc)])
    (print-block block)
    (newline)))

;; Print wallets.
(define (print-wallets bc wallet-a wallet-b)
  (printf "\nWallet A balance: ~a\nWallet B balance: ~a\n\n"
          (balance-wallet-blockchain bc wallet-a)
          (balance-wallet-blockchain bc wallet-b)))
