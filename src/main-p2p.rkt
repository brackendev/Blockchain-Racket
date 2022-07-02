#lang racket

(require "blockchain.rkt"
         "structs.rkt"
         "transaction.rkt"
         "transaction-io.rkt"
         "utils.rkt"
         "wallet.rkt")

(provide export-loop
         get-blockchain
         initialize-new-blockchain
         mine-loop
         string-to-peer-info)

(define args (vector->list (current-command-line-arguments)))

;; Parse the command-line arguments.
(when (not (= 3 (length args)))
  (begin
    (printf "Usage: main-p2p.rkt db.data port ip1:port1,ip2:port2...")
    (newline)
    (exit)))

;; Helper to parse peers' information.
(define (string-to-peer-info s)
  (let ([s (string-split s ":")])
    (peer-info (car s) (string->number (cadr s)))))

(define db-filename (car args))

(define port (string->number (cadr args)))

(define valid-peers (map string-to-peer-info (string-split (caddr args) ",")))

(define wallet-a (make-wallet))

;; Create a new blockchain.
(define (initialize-new-blockchain)
  (begin
    (define coin-base (make-wallet))

    (printf "Making genesis transaction...\n")
    (define genesis-tr (make-transaction #:from-wallet coin-base
                                         #:inputs '()
                                         #:to-wallet wallet-a
                                         #:value 100))

    (define utxo (list (make-transaction-io #:owner-wallet wallet-a #:value 100)))

    (printf "Mining genesis block...\n")
    (define bc (init-blockchain #:genesis-tr genesis-tr
                                #:seed-hash "l337cafe"
                                #:utxo utxo))
    bc))

;; Return a blockchain if the previous one exists. If not, create a new one.
(define db-blockchain
  (if (file-exists? db-filename)
      (file->struct db-filename)
      (initialize-new-blockchain)))

;; Initialize a peer with data parsed from command-line arguments.
(define peer-context (peer-context-data "Test peer"
                                        port
                                        (list->set valid-peers)
                                        '()
                                        db-blockchain))

(define (get-blockchain) (peer-context-data-blockchain peer-context))

;; Continually persist the database.
(define (export-loop) (begin
                        (sleep 10)
                        (struct->file (get-blockchain) db-filename)
                        (printf "Exported blockchain to '~a'...\n" db-filename)
                        (export-loop)))
(thread export-loop)

;; Continually mine blocks.
(define (mine-loop)
  (let ([newer-blockchain
         (send-money-blockchain #:blockchain (get-blockchain)
                                #:contract (file->contract "contract.script")
                                #:from-wallet wallet-a
                                #:to-wallet wallet-a
                                #:value 1)])
    (set-peer-context-data-blockchain! peer-context newer-blockchain)
    (printf "Mined a block!\n")
    (sleep 5)
    (mine-loop)))
(mine-loop)
