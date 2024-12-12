#lang rosette
(require json)
(require "../sentinel/utils.rkt")
(require (prefix-in anvil:: "../sentinel/anvil.rkt"))
(require (prefix-in ebc:: "../sentinel/ebc.rkt"))
(require (prefix-in synth:: "../sentinel/synth.rkt"))

; ==============================
; this tests synthesis utilities
; ==============================
(define __ null)
(define bn-latest 21380960) ; latest block number
(define bn-ad 14684300) ; block for attack deployment (step 0)
(define addr-me "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266")
(define addr-atk "0x63341ba917de90498f3903b199df5699b4a55ac0")
(define addr-atk-number (hexstr->number addr-atk))
(printf "# addr-atk-number: ~a\n" addr-atk-number)

; connect anvil server
(define sv (anvil::serv "127.0.0.1" 8545 "/"))
; disable automine
(set! __ (anvil::evm_setAutomine sv #f))
; reset block number to latest
(set! __ (anvil::anvil_resetBlockNumber sv bn-latest))

; retrieve attack step 0 (deployment)
(define bk0 (anvil::eth_getBlockByNumber sv bn-ad))
(define tx0 (list-ref (hash-ref bk0 'transactions) 157)) ; 157 is the tx index
(define in0 (hash-ref tx0 'input))
(define prog0 (ebc::hexstr->ebc in0)) ; parse
(define sketch0 (synth::make-sketch/addr prog0 addr-atk-number)) ; make sketch
; (define holes0 (synth::collect-holes sketch0))
; (printf "# holes0: ~a\n" holes0)

(define vocab (make-hash (list
    (cons 'address  (list
        (hexstr->number addr-atk)
        (hexstr->number addr-me)
    ))
)))

(define enmtr (synth::make-enmtr/sketch vocab sketch0))
(define prog1 (synth::next! enmtr))
(define prog2 (synth::next! enmtr))
; (define str1 (ebc::ebc->hexstr prog1))
; (printf "# str1: ~a\n" str1)

(printf "# eq1: ~a\n" (equal? in0 (ebc::ebc->hexstr prog1)))
(printf "# eq2: ~a\n" (equal? in0 (ebc::ebc->hexstr prog2)))