#lang racket

(require racket/serialize
         threading
         "blockchain.rkt"
         "structs.rkt")

(provide accept-and-handle
         connect-and-handle
         get-blockchain-effort
         get-potential-peers
         handler
         maybe-update-blockchain
         maybe-update-valid-peers
         peers/connect
         peers/serve
         peers/sync-data
         run-peer
         trim-helper)

;;; ========== HANDLER ==========

;; Used by the server and the client. It accepts commands:
;; REQUEST                RESPONSE
;;
;; get-valid-peers        valid-peers:X
;; (A peer may request a list of valid peers. This response automatically triggers the valid-peers command.)
;;
;; get-latest-blockchain  latest-blockchain:X
;; (A peer may request the latest blockchain from another peer. This should trigger the latest-blockchain command.)
;;
;; latest-blockchain:X
;; (When a peer gets this request, it will update the blockchain if it is valid.)
;;
;; valid-peers:X
;; (When a peer gets this request, it will update the list of valid peers.)
(define (handler peer-context in out)
  (flush-output out)
  (define line (read-line in))
  (when (string? line) ; It can be eof.
    (cond [(string-prefix? line "get-valid-peers")
           (fprintf out "valid-peers:~a\n"
                    (serialize
                     (set->list
                      (peer-context-data-valid-peers peer-context))))
           (handler peer-context in out)]
          [(string-prefix? line "get-latest-blockchain")
           (fprintf out "latest-blockchain:")
           (write
            (serialize (peer-context-data-blockchain peer-context)) out)
           (handler peer-context in out)]
          [(string-prefix? line "latest-blockchain:")
           (begin (maybe-update-blockchain peer-context line)
                  (handler peer-context in out))]
          [(string-prefix? line "valid-peers:")
           (begin (maybe-update-valid-peers peer-context line)
                  (handler peer-context in out))]
          [(string-prefix? line "exit")
           (fprintf out "bye\n")]
          [else (handler peer-context in out)])))

;; Update the blockchain and the list of valid peers if the blackchain is valid and it has a higher effort.
(define (maybe-update-blockchain peer-context line)
  (let ([latest-blockchain
         (trim-helper line #rx"(latest-blockchain:|[\r\n]+)")]
        [current-blockchain
         (peer-context-data-blockchain peer-context)])
    (when (and (valid-blockchain? latest-blockchain)
               (> (get-blockchain-effort latest-blockchain)
                  (get-blockchain-effort current-blockchain)))
      (printf "Blockchain updated for peer ~a\n"
              (peer-context-data-name peer-context))
      (set-peer-context-data-blockchain! peer-context
                                         latest-blockchain))))

;; The blockchain effort is the sum of all blocks' nonces.
(define (get-blockchain-effort bc)
  (foldl + 0 (map block-nonce (blockchain-blocks bc))))

;; Update the list of valid peers by merging the current list of valid peers with the received list.
(define (maybe-update-valid-peers peer-context line)
  (let ([valid-peers (list->set
                      (trim-helper line #rx"(valid-peers:|[\r\n]+)"))]
        [current-valid-peers (peer-context-data-valid-peers
                              peer-context)])
    (set-peer-context-data-valid-peers!
     peer-context
     (set-union current-valid-peers valid-peers))))

;; Helper to remove a command (prefix) from a string.
(define (trim-helper line x)
  (~> (string-replace line x "")
      (open-input-string)
      (read)
      (deserialize)))

;;; ========== SERVER ==========

;; Accept a connection (listener object) and a peer context and launch handler in a thread for every incoming connection.
(define (accept-and-handle listener peer-context)
  (define-values (in out) (tcp-accept listener))
  (thread
   (λ ()
     (handler peer-context in out)
     (close-input-port in))))

;; Main server listener.
;; A custodian is a container that ensures there are no bogus threads or input/output ports in memory.
(define (peers/serve peer-context)
  (define main-cust (make-custodian))
  (parameterize ([current-custodian main-cust])
    (define listener
      (tcp-listen (peer-context-data-port peer-context) 5 #t))
    (define (loop)
      (accept-and-handle listener peer-context)
      (loop))
    (thread loop))
  (λ ()
    (custodian-shutdown-all main-cust)))

;;; ========== CLIENT ==========

;; Attempts to connect to other peers:
;; 1. tcp-connect tries to make a connection to an IP address and port (from peer-info).
;; 2. When connection is successful, it wil return the input/output ports to read/write data.
;; 3. The connected peers for the current context will be updated.
;; 4. A thread is launched using handler to handle the communication. When the connection is finished, a cleanup is done and the peer is removed from the list of peers.
(define (connect-and-handle peer-context peer)
  (begin
    (define-values (in out)
      (tcp-connect (peer-info-ip peer)
                   (peer-info-port peer)))
    (define current-peer-io (peer-info-io peer in out))

    (set-peer-context-data-connected-peers!
     peer-context
     (cons current-peer-io
           (peer-context-data-connected-peers peer-context)))

    (thread
     (λ ()
       (handler peer-context in out)
       (close-input-port in)
       (close-output-port out)

       (set-peer-context-data-connected-peers!
        peer-context
        (set-remove
         (peer-context-data-connected-peers peer-context)
         current-peer-io))))))

;; Make sure connections are made to all known peers.
(define (peers/connect peer-context)
  (define main-cust (make-custodian))
  (parameterize ([current-custodian main-cust])
    (define (loop)
      (let ([potential-peers (get-potential-peers peer-context)])
        (for ([peer potential-peers])
          (with-handlers ([exn:fail? (λ (x) #t)])
            (connect-and-handle peer-context peer))))
      (sleep 10)
      (loop))
    (thread loop))
  (λ ()
    (custodian-shutdown-all main-cust)))

;; Get a list of connected and valid peers from the peer context. The valid peers that are not in the list of connected peers are potential peers to make new connections with.
(define (get-potential-peers peer-context)
  (let ([current-connected-peers
         (list->set
          (map peer-info-io-peer-info
               (peer-context-data-connected-peers peer-context)))]
        [valid-peers (peer-context-data-valid-peers peer-context)])
    (set-subtract valid-peers current-connected-peers)))

;; Ping all connected peers to sync blockchain data and valid peers.
(define (peers/sync-data peer-context)
  (define (loop)
    (sleep 10)
    (for [(p (peer-context-data-connected-peers peer-context))]
      (let ([in (peer-info-io-input-port p)]
            [out (peer-info-io-output-port p)])
        (fprintf out "get-latest-blockchain\nget-valid-peers\n")
        (flush-output out)))
    (printf "Peer ~a reports ~a valid and ~a connected peers.\n"
            (peer-context-data-name peer-context)
            (set-count
             (peer-context-data-valid-peers peer-context))
            (set-count
             (peer-context-data-connected-peers peer-context)))
    (loop))
  (define t (thread loop))
  (λ ()
    (kill-thread t)))

;;; ========== ENTRY POINT ==========

(define (run-peer peer-context)
  (begin
    (peers/serve peer-context)
    (peers/connect peer-context)
    (peers/sync-data peer-context)))
