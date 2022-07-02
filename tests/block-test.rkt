#lang racket/base

(require rackunit
         "../src/block.rkt"
         "../src/structs.rkt")

(provide block-tests)

(module+ test
  (require rackunit/text-ui)
  (run-tests block-tests))

(define tr (transaction "from" '() '() "signature" "to" 123))

(define bl (block "616263" 1 "646566" 321 tr))

(define bl-hash (calculate-block-hash #:nonce (block-nonce bl)
                                      #:previous-hash (block-previous-hash bl)
                                      #:timestamp (block-timestamp bl)
                                      #:transaction tr))

(define mined-bl (make-and-mine-block #:nonce (block-nonce bl)
                                      #:previous-hash (block-previous-hash bl)
                                      #:timestamp (block-timestamp bl)
                                      #:transaction tr))

(define block-tests
  (test-suite
   "block tests"

   ;; calculate-block-hash

   (test-equal? "calculate-block-hash"
                bl-hash
                "f03c1f8ded97f0ba831de2f3b92993d2f59b89065a214de850632ae477950393")

   ;; mine-block

   (test-true "mine-block #t"
              (> (block-nonce (mine-block #:previous-hash (block-previous-hash bl)
                                          #:transaction (block-transaction bl)))
                 1))

   ;; mined-block?

   (test-false "mined-block? #f"
               (mined-block? (block-current-hash bl)))

   (test-true "mined-block? #t"
              (mined-block? (block-current-hash mined-bl)))

   ;; valid-block?

   (test-false "valid-block? #f"
               (valid-block? bl))

   (test-true "valid-block? #t"
              (valid-block? mined-bl))))
