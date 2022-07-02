#lang racket/base

(require rackunit
         "../src/peer-to-peer.rkt")

(provide peer-to-peer-tests)

(module+ test
  (require rackunit/text-ui)
  (run-tests peer-to-peer-tests))

(define peer-to-peer-tests
  (test-suite
   "peer-to-peer tests"

   ;; TODO: accept-and-handle

   ;; TODO: connect-and-handle

   ;; TODO: get-blockchain-effort

   ;; TODO: get-potential-peers

   ;; TODO: handler

   ;; TODO: maybe-update-blockchain

   ;; TODO: maybe-update-valid-peers

   ;; TODO: peers/connect

   ;; TODO: peers/serve

   ;; TODO: peers/serve

   ;; TODO: peers/sync-data

   ;; TODO: run-peer

   ;; TODO: trim-helper

   ))
