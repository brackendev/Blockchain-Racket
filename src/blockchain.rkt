#lang racket

(require "block.rkt"
         "smart-contracts.rkt"
         "structs.rkt"
         "transaction.rkt"
         "transaction-io.rkt"
         "utils.rkt")

(provide add-transaction-to-blockchain
         balance-wallet-blockchain
         init-blockchain
         mining-reward-factor
         receiver-transaction-inputs
         send-money-blockchain
         valid-blockchain?)

;; Block reward starts at 50 coins for the first block...
(define block-reward 50)

;; ...and halves every 210,000 blocks. In other words, every block up until 210,000 will reward 50 coins, while block 210,001 will reward 25. Formula:
;; 2(b/210000)
;; -----------
;;     50
(define reward-halved 210000)

;; Blockchain initialization:
;; It accepts the genesis transaction, genesis hash, and UTXO.
;;
;; Example initialization:
;; (define coin-base (make-wallet))
;; (define wallet (make-wallet))
;; (define genesis-tr (make-transaction #:from-wallet coin-base
;;                                      #:inputs '()
;;                                      #:to-wallet wallet
;;                                      #:value 100)
;; (define utxo (list (make-transaction-io #:owner-wallet wallet
;;                                         #:value 100)
;; (define blockchain1 (init-blockchain #:genesis-tr genesis-tr
;;                                      #:seed-hash "616263"
;;                                      #:utxo utxo)
(define (init-blockchain #:genesis-tr tr
                         #:seed-hash seed
                         #:utxo utxo)
  (blockchain (cons (mine-block #:previous-hash seed
                                #:transaction (process-transaction tr))
                    '())
              utxo))

;; Start with block-reward initially and halve them on ever reward-halved blocks.
(define (mining-reward-factor blocks)
  (if (> block-reward 0)
      (/ block-reward (expt 2 (floor (/ (length blocks) reward-halved))))
      0))

;; Add a transaction to the blockchain:
;; 1. Mine a block.
;; 2. Create a new UTXO based on the processed transaction outputs, inputs, and the current UTXO.
;; 3. Generate a new list of blocks by adding the newly mined block.
;; 4. Calculate the rewards based on the current UTXO.
;; Returns a new, updated blockchain.
(define (add-transaction-to-blockchain bc tr)
  (letrec ([hashed-blockchain (mine-block
                               #:previous-hash (block-current-hash (car (blockchain-blocks bc)))
                               #:transaction tr)]
           [processed-inputs (transaction-inputs tr)]
           [processed-outputs (transaction-outputs tr)]
           [utxo (set-union processed-outputs
                            (set-subtract (blockchain-utxo bc)
                                          processed-inputs))]
           [new-blocks (cons hashed-blockchain (blockchain-blocks bc))]
           [utxo-rewarded (cons (make-transaction-io
                                 #:value (mining-reward-factor new-blocks)
                                 #:owner-wallet (transaction-from tr))
                                utxo)])
    (blockchain new-blocks utxo-rewarded)))

;; Retunrs the current receiver's transaction inputs.
(define (receiver-transaction-inputs w utxo)
  (filter (λ (tr) (equal? w (transaction-io-owner tr)))
          utxo))

;; Determine the balance of a wallet -- the sum of all unsept transactions for the matching owner.
(define (balance-wallet-blockchain bc w)
  (letrec ([my-trs (receiver-transaction-inputs w (blockchain-utxo bc))])
    (foldr + 0 (map (λ (tr) (transaction-io-value tr))
                    my-trs))))

;; Send money from one wallet to another by initiating a transaction and then adding it to the blockchain for processing.
;; my-trs contains the current receiver's transaction inputs.
;; The transaction is added to the blockchain only if it is valid.
(define (send-money-blockchain #:blockchain bc
                               #:contract c
                               #:from-wallet from
                               #:to-wallet to
                               #:value value)
  (letrec ([my-trs (receiver-transaction-inputs from (blockchain-utxo bc))]
           [tr (make-transaction #:from-wallet from
                                 #:inputs my-trs
                                 #:to-wallet to
                                 #:value value)])
    (if (transaction? tr)
        (let ([processed-transaction (process-transaction tr)])
          (if (and
               (>= (balance-wallet-blockchain bc from) value)
               (valid-transaction-contract? processed-transaction c))
              (add-transaction-to-blockchain bc processed-transaction)
              bc))
        (add-transaction-to-blockchain bc '()))))

;; Determines the blockchain validity:
;; 1. All blocks are valid using valid-block?.
;; 2. Previous hashes are matching using equal? by comparing the previous hash of all blocks (except the last) to the current hash of all blocks (except the first).
;; 3. All transactions are valid using valid-transaction?.
;; 4. All blocks are mined using mined-block?.
(define (valid-blockchain? bc)
  (let ([blocks (blockchain-blocks bc)])
    (and
     (true-for-all? valid-block? blocks)
     (equal? (drop-right (map block-previous-hash blocks) 1)
             (cdr (map block-current-hash blocks)))
     (true-for-all?
      valid-transaction? (map (λ (block) (block-transaction block))
                              blocks))
     (true-for-all? mined-block? (map block-current-hash blocks)))))
