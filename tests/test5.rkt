#lang rosette
(require "../sentinel/utils.rkt")
(require (prefix-in anvil:: "../sentinel/anvil.rkt"))

; ==================================================================
; this tests the local anvil environments (with single anvil server)
; ==================================================================
; anvil port 8545 for actual execution

; connect anvil server
(define sv (anvil::serv "127.0.0.1" 8545 "/"))
; disable automine
(anvil::evm_setAutomine sv #f)

; retrieve block numbers
(define bn0 (anvil::eth_blockNumber sv))
(printf "# initial block number: ~a\n" bn0)

; forward block number to target + 1
(define res1 (anvil::anvil_resetBlockNumber sv 14684300))
(define bn1 (anvil::eth_blockNumber sv))
(printf "# forward to block number: ~a\n" bn1)
; get next block from oracle
(define next-blk (anvil::eth_getBlockByNumber sv bn1))

; reset block number to target
(define res2 (anvil::anvil_resetBlockNumber sv 14684299))
(define bn2 (anvil::eth_blockNumber sv))
(printf "# reset to block number: ~a\n" bn2)

; replay transactions
(define next-txs (hash-ref next-blk 'transactions))
; sending all txs and mine a block will be *extremely* slow
; (for ([tx next-txs])
;     (printf "# sending tx (~a): ~a\n" (hash-ref tx 'transactionIndex) (hash-ref tx 'hash))
;     (anvil::eth_sendUnsignedTransaction sv tx)
; )
(define tx0 (list-ref next-txs 0))
(printf "# sending tx ~a, original hash: ~a\n" (hash-ref tx0 'transactionIndex) (hash-ref tx0 'hash))
(define h0 (anvil::eth_sendUnsignedTransaction sv tx0))

; mine
(define res4 (anvil::evm_mine sv))
(printf "# mine: ~a\n" res4)

; get new block number
(define bn5 (anvil::eth_blockNumber sv))
(printf "# exec current block: ~a\n" bn5)