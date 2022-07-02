#lang racket

(require (only-in file/sha1 hex-string->bytes)
         (only-in sha sha256)
         (only-in sha bytes->hex-string)
         racket/serialize
         threading
         "structs.rkt")

(provide calculate-block-hash
         make-and-mine-block
         mine-block
         mined-block?
         valid-block?)

;; Number of bytes.
(define difficulty 2)

;; Contain the difficulty number of bytes.
(define target (bytes->hex-string (make-bytes difficulty 32)))

;; Calculate a block's hash.
(define (calculate-block-hash #:nonce nonce
                              #:previous-hash previous-hash
                              #:timestamp timestamp
                              #:transaction transaction)
  (~> (bytes-append
       (string->bytes/utf-8 (number->string nonce))
       (string->bytes/utf-8 previous-hash)
       (string->bytes/utf-8 (number->string timestamp))
       (string->bytes/utf-8 (~a (serialize transaction))))
      (sha256)
      (bytes->hex-string)))

;; Validate a block's hash against the hash stored in the block.
(define (valid-block? bl)
  (equal? (block-current-hash bl)
          (calculate-block-hash #:nonce (block-nonce bl)
                                #:previous-hash (block-previous-hash bl)
                                #:timestamp (block-timestamp bl)
                                #:transaction (block-transaction bl))))

;; A block is mined if the hash matches the target.
;; hex-string->bytes converts "0102030304" to #"\1\2\3\3\4", for ex.
;; subbytes takes a list of bytes, a start, and an end point and retunrs a sublist.
;; With a random hash, it is valid if its first type bytes match the target.
(define (mined-block? block-hash)
  (equal? (subbytes (hex-string->bytes block-hash) 0 difficulty)
          (subbytes (hex-string->bytes target) 0 difficulty)))

;; Proof of work:
;; Nonce is increased until a block is valid, then the block is returned.
;; Nonce is changed until sha256 produces a hash that matches the target.
(define (make-and-mine-block #:nonce nonce
                             #:previous-hash previous-hash
                             #:timestamp timestamp
                             #:transaction transaction)
  (let ([current-hash (calculate-block-hash #:nonce nonce
                                            #:previous-hash previous-hash
                                            #:timestamp timestamp
                                            #:transaction transaction)])
    (if (mined-block? current-hash)
        (block current-hash nonce previous-hash timestamp transaction)
        (make-and-mine-block #:nonce (+ nonce 1)
                             #:previous-hash previous-hash
                             #:timestamp timestamp
                             #:transaction transaction))))

;; Helper to mine a new block.
(define (mine-block #:previous-hash previous-hash #:transaction transaction)
  (make-and-mine-block #:nonce 1
                       #:previous-hash previous-hash
                       #:timestamp (current-milliseconds)
                       #:transaction transaction))
