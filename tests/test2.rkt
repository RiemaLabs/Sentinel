#lang rosette
(require (prefix-in anvil:: "../sentinel/anvil.rkt"))
(require (prefix-in ebc:: "../sentinel/ebc.rkt"))

; ===================================
; this tests the evm bytecode parsing
; ===================================

(define sv0 (anvil::serv "127.0.0.1" 8545 "/"))
(define b0 (anvil::eth_getBlockByNumber sv0 14684300))
(define tx0 (list-ref (hash-ref b0 'transactions) 157))
(printf "tx0: ~a\n" tx0)
(define rs0 (hash-ref tx0 'input))
; (printf "rs0: ~a\n" rs0)

; simplified version
; (define rs0 "0x6080604052348015600e575f80fd5b506101438061001c5f395ff3fe608060405234801561000f575f80fd5b5060043610610034575f3560e01c80632e64cec1146100385780636057361d14610056575b5f80fd5b610040610072565b60405161004d919061009b565b60405180910390f35b610070600480360381019061006b91906100e2565b61007a565b005b5f8054905090565b805f8190555050565b5f819050919050565b61009581610083565b82525050565b5f6020820190506100ae5f83018461008c565b92915050565b5f80fd5b6100c181610083565b81146100cb575f80fd5b50565b5f813590506100dc816100b8565b92915050565b5f602082840312156100f7576100f66100b4565b5b5f610104848285016100ce565b9150509291505056fea26469706673582212209a0dd35336aff1eb3eeb11db76aa60a1427a12c1b92f945ea8c8d1dfa337cf2264736f6c634300081a0033")

(define ebc0 (ebc::hexstr->ebc rs0))
; (printf "ebc0: ~a\n" ebc0)

(define hs0 (ebc::ebc->hexstr ebc0))
; (printf "hs0: ~a\n" hs0)

(printf "check: ~a\n" (equal? hs0 rs0))