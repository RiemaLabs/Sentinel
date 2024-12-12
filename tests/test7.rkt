#lang rosette
(require json)
(require "../sentinel/utils.rkt")
(require (prefix-in anvil:: "../sentinel/anvil.rkt"))

; =================================
; this reproduces key steps in demo
; =================================

; ==========================
; ==== helper functions ====
; ==========================
(define (hexstr+ a b) (number->hexstr (+ (hexstr->number a) (hexstr->number b)) 0 #t))
(define (hexstr* a b) (number->hexstr (* (hexstr->number a) (hexstr->number b)) 0 #t))
; increase the gas to avoid out of gas (an anvil's bug caused by the anvil_resetBlockNumber procedure)
(define (gas-patch tx)
    (hash-set tx 'gas (hexstr* (hash-ref tx 'gas) "0x2")) ; double
)

; ==========================
; ==== global variables ====
; ==========================
(define __ null)
(define bn-latest 21380960) ; latest block number
(define bn-ad 14684300) ; block for attack deployment (step 0)
(define bn-ac 14684307) ; block for attack execution (step 1)
(define addr-me "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266")
(define addr-atk "0x63341ba917de90498f3903b199df5699b4a55ac0")

; ==============================
; ==== global configuration ====
; ==============================

; connect anvil server
(define sv (anvil::serv "127.0.0.1" 8545 "/"))
; disable automine
(set! __ (anvil::evm_setAutomine sv #f))
; reset block number to latest
(set! __ (anvil::anvil_resetBlockNumber sv bn-latest))

; ===============================
; ==== benchmark preparation ====
; ===============================

; retrieve attack step 0 (deployment)
(define bk0 (anvil::eth_getBlockByNumber sv bn-ad))
(define tx0 (gas-patch (list-ref (hash-ref bk0 'transactions) 157))) ; 157 is the tx index
; retrieve attack step 1 (attack)
(define bk1 (anvil::eth_getBlockByNumber sv bn-ac))
(define tx1 (gas-patch (list-ref (hash-ref bk1 'transactions) 212))) ; 212 is the tx index
; reset block to 1 block before deployment
(set! __ (anvil::anvil_resetBlockNumber sv (- bn-ad 1)))

; fund myself
(set! __ (anvil::anvil_setBalance sv addr-me 9999999999999999999999999999))

; ==========================
; ==== start mitigation ====
; ==========================

(printf "# start mitigation\n")

; modify tx0's input
(define in0 (hash-ref tx0 'input))
(define in0-modified (let ([in0 (hash-ref tx0 'input)])
    (string-replace (string-downcase in0) addr-atk addr-me)
))
(define tx0-modified (make-hash (list
    (cons 'from addr-me) ; modified
    (cons 'to (hash-ref tx0 'to))
    (cons 'gas (hash-ref tx0 'gas)) ; FIXME: need to modify
    (cons 'gasPrice (hash-ref tx0 'gasPrice)) ; FIXME: need to modify
    (cons 'value (hash-ref tx0 'value)) ; FIXME: need to modify
    (cons 'input in0-modified) ; modified
)))

; send tx0
(define hash0 (anvil::eth_sendUnsignedTransaction sv tx0-modified))
; (printf "# hash0: ~a\n" hash0)
; need to mine before getting the address
(set! __ (anvil::evm_mine sv))
; get receipt
(define receipt0 (anvil::eth_getTransactionReceipt sv hash0))
(printf "# tx0 status: ~a\n" (hash-ref receipt0 'status))
; FIXME: address can be computed given the bytecode already without mining
(define addr0 (hash-ref receipt0 'contractAddress))
(printf "# tx0-modified addr: ~a\n" addr0)

; construct tx1 (attack)
(define tx1-modified (make-hash (list
    (cons 'from addr-me)
    (cons 'to addr0)
    (cons 'gas (hash-ref tx0-modified 'gas)) ; reuse
    (cons 'gasPrice (hash-ref tx0-modified 'gasPrice)) ; reuse
    (cons 'value (hash-ref tx0-modified 'value)) ; reuse
    (cons 'input "0xaf8271f7") ; FIXME: attack function selector (hardcoded)
)))

; send tx1
(define hash1 (anvil::eth_sendUnsignedTransaction sv tx1-modified))
; (printf "# hash1: ~a\n" hash1)
; mine
(set! __ (anvil::evm_mine sv))
; get receipt
(define receipt1 (anvil::eth_getTransactionReceipt sv hash1))
(printf "# tx1 status: ~a\n" (hash-ref receipt1 'status))

(printf "# end mitigation\n")

; ================================
; ==== replay original attack ====
; ================================

(printf "# start validation (replay of attacker's transactions)\n")

(define h0 (anvil::eth_sendUnsignedTransaction sv tx0))
(set! __ (anvil::evm_mine sv))
(define r0 (anvil::eth_getTransactionReceipt sv h0))
(printf "# tx0 status: ~a\n" (hash-ref r0 'status))

(define h1 (anvil::eth_sendUnsignedTransaction sv tx1))
(set! __ (anvil::evm_mine sv))
(define r1 (anvil::eth_getTransactionReceipt sv h1))
(printf "# tx1 status: ~a\n" (hash-ref r1 'status))

(printf "# end validation\n")

(printf "# done")