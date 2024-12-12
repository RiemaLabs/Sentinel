#lang rosette
(require (prefix-in anvil:: "../sentinel/anvil.rkt"))

; ==========================
; this tests the anvil utils
; ==========================

(define sv0 (anvil::serv "127.0.0.1" 8545 "/"))

(define data0 (anvil::rpc-cmd "eth_blockNumber" null 67))
(define-values (k0 b0) (anvil::rpc sv0 data0))
(printf "status0: ~a\n" k0)
(printf "body0: ~a\n" b0)

(define-values (k1 b1) (anvil::eth_blockNumber sv0 #:raw? #t))
(printf "status1: ~a\n" k1)
(printf "body1: ~a\n" b1)

(define-values (k2 b2) (anvil::eth_getBlockByNumber sv0 14684300 #:raw? #t))
(printf "status2: ~a\n" k2)
(printf "body2: ~a\n" b2)