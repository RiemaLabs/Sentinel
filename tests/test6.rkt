#lang rosette
(require "../sentinel/utils.rkt")
(require (prefix-in anvil:: "../sentinel/anvil.rkt"))

; ===================================
; this tests the getBalance procedure
; ===================================
; anvil port 8545 for actual execution

; connect anvil server
(define sv (anvil::serv "127.0.0.1" 8545 "/"))
; disable automine
(define _0 (anvil::evm_setAutomine sv #f))

(define addr0 "0x63341Ba917De90498F3903B199Df5699b4a55AC0")
(define bal0 (anvil::eth_getBalance sv addr0))
(printf "# bal0: ~a\n" bal0)