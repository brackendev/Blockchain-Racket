#lang racket

(require racket/serialize)

(provide file->contract
         file->struct
         struct->file
         true-for-all?)

;; Helper to read contracts:
;; with-handlers accepts a procedure that handles failures.
(define (file->contract file)
  (with-handlers ([exn:fail? (λ (exn) '())])
    (read (open-input-file file))))

;; Import a struct from a file.
(define (file->struct file)
  (letrec ([in (open-input-file file)]
           [result (read in)])
    (close-input-port in)
    (deserialize result)))

;; Export a struct to a file.
(define (struct->file object file)
  (let ([out (open-output-file file #:exists 'replace)])
    (write (serialize object) out)
    (close-output-port out)))

;; Returns true if a predicate is satisfied.
;; Examples:
;; > (true-for-all? (λ (x) (> x 3)) '(1 2 3))
;; #f
;; > (true-for-all? (λ (x) (> x 3)) '(4 5 6))
;; #t
(define (true-for-all? pred list)
  (cond
    [(empty? list) #t]
    [(pred (car list)) (true-for-all? pred (cdr list))]
    [else #f]))
