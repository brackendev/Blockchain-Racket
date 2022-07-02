#lang racket

(require "structs.rkt"
         "transaction.rkt")

(provide eval-contract
         valid-transaction-contract?)

;; Check a transaction signature with contract.
(define (valid-transaction-contract? tr c)
  (and (eval-contract tr c)
       (valid-transaction? tr)))

;; Accept a transaction and contract and return a value.
;; Examples:
;; > (eval-contract tr 123)
;; 123
;; > (eval-contract tr "Hi")
;; "Hi"
;; > (eval-contract tr '())
;; #t
(define (eval-contract tr c)
  (match c
    [(? number? x) x]
    [(? string? x) x]
    [`() #t]
    [`true #t]
    [`false #f]
    [`(if ,co ,tt ,fa) (if (eval-contract tr co)
                           (eval-contract tr tt)
                           (eval-contract tr fa))]
    [`(+ ,l ,r) (+ (eval-contract tr l) (eval-contract tr r))]
    [`(* ,l ,r) (* (eval-contract tr l) (eval-contract tr r))]
    [`(- ,l ,r) (- (eval-contract tr l) (eval-contract tr r))]
    [`(= ,l ,r) (= (eval-contract tr l) (eval-contract tr r))]
    [`(> ,l ,r) (> (eval-contract tr l) (eval-contract tr r))]
    [`(< ,l ,r) (< (eval-contract tr l) (eval-contract tr r))]
    [`(and ,l ,r) (and (eval-contract tr l) (eval-contract tr r))]
    [`(or ,l ,r) (or (eval-contract tr l) (eval-contract tr r))]
    [`from (transaction-from tr)]
    [`to (transaction-to tr)]
    [`value (transaction-value tr)]
    [`#t #t]
    [else #f]))
