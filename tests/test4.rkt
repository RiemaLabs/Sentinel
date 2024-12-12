#lang rosette
(require "../sentinel/utils.rkt")
(require (prefix-in anvil:: "../sentinel/anvil.rkt"))

; =======================================================
; this tests the local anvil environments (single server)
; =======================================================
; anvil port is 8545

; retrieve block numbers
(define sv (anvil::serv "127.0.0.1" 8545 "/"))
(define bn0 (anvil::eth_blockNumber sv))
(printf "# current block number: ~a\n" bn0)

; reset to block 14684299
(define res1 (anvil::anvil_resetBlockNumber sv 14684299))
(define bn1 (anvil::eth_blockNumber sv))
(printf "# current block number: ~a\n" bn1)

; reset to block 14685000
(define res2 (anvil::anvil_resetBlockNumber sv 14685000))
(define bn2 (anvil::eth_blockNumber sv))
(printf "# current block number: ~a\n" bn2)
