#lang racket

(provide (struct-out block)
         (struct-out blockchain)
         (struct-out peer-info)
         (struct-out peer-info-io)
         (struct-out peer-context-data)
         (struct-out transaction)
         (struct-out transaction-io)
         (struct-out wallet))

(struct block (current-hash nonce previous-hash timestamp transaction) #:prefab)

;; UTXO is a list of transaction-io objects (unspent transaction outputs).
(struct blockchain (blocks utxo) #:prefab)

(struct peer-info (ip port) #:prefab)

(struct peer-info-io (peer-info input-port output-port) #:prefab)

(struct peer-context-data (name
                           port
                           [valid-peers #:mutable]
                           [connected-peers #:mutable]
                           [blockchain #:mutable])
  #:prefab)

(struct transaction (from inputs outputs signature to value) #:prefab)

(struct transaction-io (owner timestamp transaction-hash value) #:prefab)

(struct wallet (private-key public-key) #:prefab)
