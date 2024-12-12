#lang rosette
(provide (all-defined-out))

(struct ebc (vs) #:mutable #:transparent #:reflection-name 'evm-bytecode)
(struct invalid (x) #:mutable #:transparent #:reflection-name 'invalid)

(struct stop () #:mutable #:transparent #:reflection-name 'stop) ; 00
(struct add () #:mutable #:transparent #:reflection-name 'add) ; 01
(struct mul () #:mutable #:transparent #:reflection-name 'mul) ; 02
(struct sub () #:mutable #:transparent #:reflection-name 'sub) ; 03
(struct div () #:mutable #:transparent #:reflection-name 'div) ; 04
(struct sdiv () #:mutable #:transparent #:reflection-name 'sdiv) ; 05
(struct mod () #:mutable #:transparent #:reflection-name 'mod) ; 06
(struct smod () #:mutable #:transparent #:reflection-name 'smod) ; 07
(struct addmod () #:mutable #:transparent #:reflection-name 'addmod) ; 08
(struct mulmod () #:mutable #:transparent #:reflection-name 'mulmod) ; 09
(struct exp () #:mutable #:transparent #:reflection-name 'exp) ; 0a
(struct signextend () #:mutable #:transparent #:reflection-name 'signextend) ; 0b
; 0c ~ 0f are invalid

(struct lt () #:mutable #:transparent #:reflection-name 'lt) ; 10
(struct gt () #:mutable #:transparent #:reflection-name 'gt) ; 11
(struct slt () #:mutable #:transparent #:reflection-name 'slt) ; 12
(struct sgt () #:mutable #:transparent #:reflection-name 'sgt) ; 13
(struct eq () #:mutable #:transparent #:reflection-name 'eq) ; 14
(struct iszero () #:mutable #:transparent #:reflection-name 'iszero) ; 15
(struct and () #:mutable #:transparent #:reflection-name 'and) ; 16
(struct or () #:mutable #:transparent #:reflection-name 'or) ; 17
(struct xor () #:mutable #:transparent #:reflection-name 'xor) ; 18
(struct not () #:mutable #:transparent #:reflection-name 'not) ; 19
(struct byte () #:mutable #:transparent #:reflection-name 'byte) ; 1a
(struct shl () #:mutable #:transparent #:reflection-name 'shl) ; 1b
(struct shr () #:mutable #:transparent #:reflection-name 'shr) ; 1c
(struct sar () #:mutable #:transparent #:reflection-name 'sar) ; 1d
; 1e ~ 1f are invalid

(struct sha3 () #:mutable #:transparent #:reflection-name 'sha3) ; 20
; 21 ~ 2f are invalid

(struct address () #:mutable #:transparent #:reflection-name 'address) ; 30
(struct balance () #:mutable #:transparent #:reflection-name 'balance) ; 31
(struct origin () #:mutable #:transparent #:reflection-name 'origin) ; 32
(struct caller () #:mutable #:transparent #:reflection-name 'caller) ; 33
(struct callvalue () #:mutable #:transparent #:reflection-name 'callvalue) ; 34
(struct calldataload () #:mutable #:transparent #:reflection-name 'calldataload) ; 35
(struct calldatasize () #:mutable #:transparent #:reflection-name 'calldatasize) ; 36
(struct calldatacopy () #:mutable #:transparent #:reflection-name 'calldatacopy) ; 37
(struct codesize () #:mutable #:transparent #:reflection-name 'codesize) ; 38
(struct codecopy () #:mutable #:transparent #:reflection-name 'codecopy) ; 39
(struct gasprice () #:mutable #:transparent #:reflection-name 'gasprice) ; 3a
(struct extcodesize () #:mutable #:transparent #:reflection-name 'extcodesize) ; 3b
(struct extcodecopy () #:mutable #:transparent #:reflection-name 'extcodecopy) ; 3c
(struct returndatasize () #:mutable #:transparent #:reflection-name 'returndatasize) ; 3d
(struct returndatacopy () #:mutable #:transparent #:reflection-name 'returndatacopy) ; 3e
(struct extcodehash () #:mutable #:transparent #:reflection-name 'extcodehash) ; 3f

(struct blockhash () #:mutable #:transparent #:reflection-name 'blockhash) ; 40
(struct coinbase () #:mutable #:transparent #:reflection-name 'coinbase) ; 41
(struct timestamp () #:mutable #:transparent #:reflection-name 'timestamp) ; 42
(struct number () #:mutable #:transparent #:reflection-name 'number) ; 43
(struct difficulty () #:mutable #:transparent #:reflection-name 'difficulty) ; 44
(struct gaslimit () #:mutable #:transparent #:reflection-name 'gaslimit) ; 45
(struct chainid () #:mutable #:transparent #:reflection-name 'chainid) ; 46
(struct selfbalance () #:mutable #:transparent #:reflection-name 'selfbalance) ; 47
(struct basefee () #:mutable #:transparent #:reflection-name 'basefee) ; 48
(struct blobhash () #:mutable #:transparent #:reflection-name 'blobhash) ; 49
(struct blobbasefee () #:mutable #:transparent #:reflection-name 'blobbasefee) ; 4a
; 4b ~ 4f are invalid

(struct pop () #:mutable #:transparent #:reflection-name 'pop) ; 50
(struct mload () #:mutable #:transparent #:reflection-name 'mload) ; 51
(struct mstore () #:mutable #:transparent #:reflection-name 'mstore) ; 52
(struct mstore8 () #:mutable #:transparent #:reflection-name 'mstore8) ; 53
(struct sload () #:mutable #:transparent #:reflection-name 'sload) ; 54
(struct sstore () #:mutable #:transparent #:reflection-name 'sstore) ; 55
(struct jump () #:mutable #:transparent #:reflection-name 'jump) ; 56
(struct jumpi () #:mutable #:transparent #:reflection-name 'jumpi) ; 57
(struct pc () #:mutable #:transparent #:reflection-name 'pc) ; 58
(struct msize () #:mutable #:transparent #:reflection-name 'msize) ; 59
(struct gas () #:mutable #:transparent #:reflection-name 'gas) ; 5a
(struct jumpdest () #:mutable #:transparent #:reflection-name 'jumpdest) ; 5b
(struct tload () #:mutable #:transparent #:reflection-name 'tload) ; 5c
(struct tstore () #:mutable #:transparent #:reflection-name 'tstore) ; 5d
(struct mcopy () #:mutable #:transparent #:reflection-name 'mcopy) ; 5e
(struct push0 () #:mutable #:transparent #:reflection-name 'push0) ; 5f

(struct pushx (x v) #:mutable #:transparent #:reflection-name 'pushx) ; 60 (push1) ~ 7f (push32)
(struct dupx (x) #:mutable #:transparent #:reflection-name 'dupx) ; 80 (dup1) ~ 8f (dup16)
(struct swapx (x) #:mutable #:transparent #:reflection-name 'swapx) ; 90 (swap1) ~ 9f (swap16)

(struct logx (x) #:mutable #:transparent #:reflection-name 'logx) ; a0 (log0) ~ a4 (log4)
; a5 ~ af are invalid

(struct push () #:mutable #:transparent #:reflection-name 'push) ; b0
(struct dup () #:mutable #:transparent #:reflection-name 'dup) ; b1
(struct swap () #:mutable #:transparent #:reflection-name 'swap) ; b2
; b3 ~ bf are invalid

; c0 ~ cf are invalid
; d0 ~ df are invalid
; e0 ~ ef are invalid

(struct create () #:mutable #:transparent #:reflection-name 'create) ; f0
(struct call () #:mutable #:transparent #:reflection-name 'call) ; f1
(struct callcode () #:mutable #:transparent #:reflection-name 'callcode) ; f2
(struct return () #:mutable #:transparent #:reflection-name 'return) ; f3
(struct delegatecall () #:mutable #:transparent #:reflection-name 'delegatecall) ; f4
(struct create2 () #:mutable #:transparent #:reflection-name 'create2) ; f5
; f6 ~ f9 are invalid
(struct staticcall () #:mutable #:transparent #:reflection-name 'staticcall) ; fa
; f8 ~ fc are invalid
(struct revert () #:mutable #:transparent #:reflection-name 'revert) ; fd
; fe is invalid
(struct selfdestruct () #:mutable #:transparent #:reflection-name 'selfdestruct) ; ff

(define ops (list
    ; 0
    stop add mul sub div sdiv mod smod
    addmod mulmod exp signextend invalid invalid invalid invalid

    ; 1
    lt gt slt sgt eq iszero and or
    xor not byte shl shr sar invalid invalid

    ; 2
    sha3 invalid invalid invalid invalid invalid invalid invalid
    invalid invalid invalid invalid invalid invalid invalid invalid

    ; 3
    address balance origin caller callvalue calldataload calldatasize calldatacopy
    codesize codecopy gasprice extcodesize extcodecopy returndatasize returndatacopy extcodehash

    ; 4
    blockhash coinbase timestamp number difficulty gaslimit chainid selfbalance
    basefee blobhash blobbasefee invalid invalid invalid invalid invalid

    ; 5
    pop mload mstore mstore8 sload sstore jump jumpi
    pc msize gas jumpdest tload tstore mcopy push0

    ; 6
    pushx pushx pushx pushx pushx pushx pushx pushx
    pushx pushx pushx pushx pushx pushx pushx pushx

    ; 7
    pushx pushx pushx pushx pushx pushx pushx pushx
    pushx pushx pushx pushx pushx pushx pushx pushx

    ; 8
    dupx dupx dupx dupx dupx dupx dupx dupx
    dupx dupx dupx dupx dupx dupx dupx dupx

    ; 9
    swapx swapx swapx swapx swapx swapx swapx swapx
    swapx swapx swapx swapx swapx swapx swapx swapx

    ; a
    logx logx logx logx invalid invalid invalid invalid
    invalid invalid invalid invalid invalid invalid invalid invalid

    ; b
    push dup swap invalid invalid invalid invalid invalid
    invalid invalid invalid invalid invalid invalid invalid invalid

    ; c
    invalid invalid invalid invalid invalid invalid invalid invalid
    invalid invalid invalid invalid invalid invalid invalid invalid

    ; d
    invalid invalid invalid invalid invalid invalid invalid invalid
    invalid invalid invalid invalid invalid invalid invalid invalid

    ; e
    invalid invalid invalid invalid invalid invalid invalid invalid
    invalid invalid invalid invalid invalid invalid invalid invalid

    ; f
    create call callcode return delegatecall create2 invalid invalid
    invalid invalid staticcall invalid invalid revert invalid selfdestruct
))

; we need procedure name (i.e., here it's struct name) to be exactly the same as reflection name
(define ons (for/list ([op ops]) (object-name op)))

; mapping of operator to id; some ops are not accurate (e.g., invalid)
(define on2oid (make-hash (for/list ([i (range (length ons))])
    (cons (list-ref ons i) i)
)))