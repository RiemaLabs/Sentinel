#lang rosette
(require "../sentinel/utils.rkt")
(require (prefix-in anvil:: "../sentinel/anvil.rkt"))

; (deprecated)
; =======================================
; this tests the local anvil environments
; =======================================
; anvil port 8545 for actual execution
; anvil port 9876 for orcale block/tx retrieval

; retrieve block numbers
(define sv-oracle (anvil::serv "127.0.0.1" 9876 "/"))
(define sv-exec (anvil::serv "127.0.0.1" 8545 "/"))
(define oracle-bn (anvil::eth_blockNumber sv-oracle))
(define exec-bn (anvil::eth_blockNumber sv-exec))
(printf "# oracle current block: ~a, exec current block: ~a\n" oracle-bn exec-bn)

; get next block from oracle
(define next-bn (+ 1 exec-bn))
(define next-blk (anvil::eth_getBlockByNumber sv-oracle next-bn))

; send transactions to execution server
(define next-txs (hash-ref next-blk 'transactions))
; sending all txs and mine a block will be *extremely* slow
; (for ([tx next-txs])
;     (printf "# sending tx (~a): ~a\n" (hash-ref tx 'transactionIndex) (hash-ref tx 'hash))
;     (anvil::eth_sendUnsignedTransaction sv-exec tx)
; )
(define tx0 (list-ref next-txs 0))
(printf "# sending tx ~a, original hash: ~a\n" (hash-ref tx0 'transactionIndex) (hash-ref tx0 'hash))
(define h0 (anvil::eth_sendUnsignedTransaction sv-exec tx0))

; mine
(define r0 (anvil::evm_mine sv-exec))
(printf "# mine: ~a\n" r0)

; get new block number
(define now-bn (anvil::eth_blockNumber sv-exec))
(printf "# exec current block: ~a\n" now-bn)