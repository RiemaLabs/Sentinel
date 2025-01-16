#lang rosette
(require "./utils.rkt")
(require (prefix-in ebc:: "./grammar/ebc.rkt"))
(provide (all-defined-out))

; ================================== ;
; ==== evm bytecode (ebc) utils ==== ;
; ================================== ;

(define (hexstr->ebc s)
    (define s0 (string-trim (string-downcase s) "0x" #:right? #f))
    (define cs (string->list s0))
    (ebc::ebc (chars->ebc cs))
)

; convert a list of hex chars to decimal number
; e.g., (#\1 #\a) -> 26
(define (hexchars->decimal xs) (string->number (list->string xs) 16))

; cs: list of chars
;   - parse a list of chars into its evm bytecodes
(define (chars->ebc cs)
    (cond
        [(null? cs) null]
        [(>= (length cs) 2)
            (let ([c2 (take cs 2)][cr (drop cs 2)])
                (define oid (hexstr->number (list->string c2)))
                (define op (list-ref ebc::ops oid))
                (define on (list-ref ebc::ons oid))
                (cond
                    ; pushx series
                    [(equal? 'pushx on)
                        (define x (- oid #x5f))
                        ; a hex char is 4-bit, pushx requries x byte, so offset should be double x
                        (define offset (* 2 x))
                        (if (> offset (length cr))
                            ; syntax error, fall back to ending operator
                            ; this implies that we've reached the end of bytecode
                            (cons (ebc::ending (hexchars->decimal cs)) null)
                            ; syntax correct, perform normal parsing
                            (let ([r0 (take cr offset)][crr (drop cr offset)])
                                (define v0 (hexchars->decimal r0))
                                (cons (ebc::pushx x v0) (chars->ebc crr))
                            )
                        )
                    ]
                    ; dupx series
                    [(equal? 'dupx on)
                        (define x (- oid #x7f))
                        (cons (ebc::dupx x) (chars->ebc cr))
                    ]
                    ; swapx series
                    [(equal? 'swapx on)
                        (define x (- oid #x8f))
                        (cons (ebc::swapx x) (chars->ebc cr))
                    ]
                    ; logx series
                    [(equal? 'logx on)
                        (define x (- oid #xa0))
                        (cons (ebc::logx x) (chars->ebc cr))
                    ]
                    ; invalid series
                    [(equal? 'invalid on)
                        (cons (ebc::invalid oid) (chars->ebc cr))
                    ]
                    ; all other operators, no look-forward needed
                    [else (cons (op ) (chars->ebc cr))]
                )
            )
        ]
        [else (error 'chars->ebc (format "invalid chars: ~a" cs))]
    )
)

(define (ebc->hexstr e [prefix? #t])
    (define ops (ebc::ebc-vs e))
    (if prefix? (format "0x~a" (ops->hexstr ops)) (ops->hexstr ops))
)

(define (ops->hexstr os)
    (if (null? os)
        "" ; end
        (let* ([op0 (car os)][on0 (struct-name op0)][opr (cdr os)])
            (format "~a~a"
                (cond
                    ; pushx series
                    [(equal? 'pushx on0) (let ([x (ebc::pushx-x op0)][v (ebc::pushx-v op0)])
                        (format "~a~a"
                            (number->hexstr (+ #x5f x) 2 #f)
                            (number->hexstr v (* 2 x) #f)
                        )
                    )]
                    ; dupx series
                    [(equal? 'dupx on0) (number->hexstr (+ #x7f (ebc::dupx-x op0)) 2 #f)]
                    ; swapx series
                    [(equal? 'swapx on0) (number->hexstr (+ #x8f (ebc::swapx-x op0)) 2 #f)]
                    ; logx series
                    [(equal? 'logx on0) (number->hexstr (+ #xa0 (ebc::logx-x op0)) 2 #f)]
                    ; invalid series
                    [(equal? 'invalid on0) (number->hexstr (ebc::invalid-x op0) 2 #f)]
                    ; ending operator
                    [(equal? 'ending on0) (number->hexstr (ebc::ending-v op0) 2 #f)]
                    ; all other operators
                    [else (number->hexstr (hash-ref ebc::on2oid on0) 2 #f)]
                )
                (ops->hexstr opr)
            )
        )
    )
)