#lang racket/base

(require rackunit
         "../src/utils.rkt")

(provide utils-tests)

(module+ test
  (require rackunit/text-ui)
  (run-tests utils-tests))

(define utils-tests
  (test-suite
   "utils tests"

   ;; TODO: file->contract

   ;; TODO: file->struct

   ;; TODO: struct->file

   ;; true-for-all?

   (test-false "true-for-all? #f"
               (true-for-all? (λ (x) (> x 3)) '(0 1 2)))

   (test-true "true-for-all? #t"
              (true-for-all? (λ (x) (> x 3)) '(4 5 6)))))
