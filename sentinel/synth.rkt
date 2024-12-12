#lang rosette
(require "./utils.rkt")
(require (prefix-in ebc:: "./grammar/ebc.rkt"))
(require (prefix-in ebc:: "./ebc.rkt"))
(provide (all-defined-out))

; id (int) | type (symbol) | v (any): null means not finalized 
(struct hole (id type v) #:mutable #:transparent #:reflection-name 'hole)

; vocab (hash<symbol, list<int>>) | sketch (ebc) | holes (list<hole>) | state (list<list<int>>)
(struct enmtr (vocab sketch holes state) #:mutable #:transparent #:reflection-name 'enmtr)
; make enumerator from a given sketch
(define (make-enmtr/sketch vocab node)
    (define holes (collect-holes node))
    (define seeds (for/list ([h holes]) (hash-ref vocab (hole-type h))))
    (define state (apply cartesian-product seeds))
    (enmtr vocab node holes state)
)
; (in place) get next candidate
; assign? (bool): whether or not to return the current assignment together
(define (next! e #:assign? [assign? #f])
    (let ([state (enmtr-state e)][node (enmtr-sketch e)])
        (if (null? state)
            #f ; exhausted
            (let ([curr (car state)][rrrr (cdr state)])
                (set-enmtr-state! e rrrr)
                (if assign?
                    (values curr (complete-sketch node curr))
                    (complete-sketch node curr)
                )
            )
        )
    )
)

; node (ebc) | addr (hexstr) | hbox (box of int): hole id counter (helper)
(define (make-sketch/addr node addr [hbox (box 0)])
    (cond
        [(ebc::ebc? node) (ebc::ebc (for/list ([n (ebc::ebc-vs node)]) (make-sketch/addr n addr hbox)))]
        [(ebc::pushx? node) (let ([x (ebc::pushx-x node)][v (ebc::pushx-v node)])
            (if (&& (equal? 20 x) (equal? addr v))
                (let ([hid (unbox hbox)])
                    (set-box! hbox (+ 1 hid)) ; increase hid
                    (ebc::pushx x (hole hid 'address null)) ; replace with a hole, id will sort out later
                )
                (ebc::pushx x v) ; keep
            )
        )]
        [(ebc::dupx? node) (ebc::dupx (ebc::dupx-x node))] ; copy
        [(ebc::swapx? node) (ebc::swapx (ebc::swapx-x node))] ; copy
        [(ebc::logx? node) (ebc::logx (ebc::logx-x node))] ; copy
        [(ebc::invalid? node) (ebc::invalid (ebc::invalid-x node))] ; copy
        [else ((struct-constructor node))] ; direct copy
    )
)

; node (ebc)
; return (list of holes)
(define (collect-holes node)
    (cond
        [(ebc::ebc? node)
            (define ret (apply append (for/list ([n (ebc::ebc-vs node)]) (collect-holes n))))
            ; sort the hole list by id
            (sort ret < #:key hole-id)
        ]
        [(ebc::pushx? node) (let ([x (ebc::pushx-x node)][v (ebc::pushx-v node)])
            (append
                (if (hole? x) (list x) null)
                (if (hole? v) (list v) null)
            )
        )]
        [(ebc::dupx? node) (let ([x (ebc::dupx-x node)])
            (if (hole? x) (list x) null)
        )]
        [(ebc::swapx? node) (let ([x (ebc::swapx-x node)])
            (if (hole? x) (list x) null)
        )]
        [(ebc::logx? node) (let ([x (ebc::logx-x node)])
            (if (hole? x) (list x) null)
        )]
        [(ebc::invalid? node) (let ([x (ebc::invalid-x node)])
            (if (hole? x) (list x) null)
        )]
        [(hole? node) (list node)]
        [else null]
    )
)

; return a new copy of concretized sketch
; node (ebc) | assignment (list<any>)
(define (complete-sketch node assignment)
    (cond
        [(ebc::ebc? node) (ebc::ebc (for/list ([n (ebc::ebc-vs node)]) (complete-sketch n assignment)))]
        [(ebc::pushx? node) (let ([x (ebc::pushx-x node)][v (ebc::pushx-v node)])
            (define new-x (if (hole? x) (list-ref assignment (hole-id x)) x))
            (define new-v (if (hole? v) (list-ref assignment (hole-id v)) v))
            (ebc::pushx new-x new-v)
        )]
        [(ebc::dupx? node) (let ([x (ebc::dupx-x node)])
            (define new-x (if (hole? x) (list-ref assignment (hole-id x)) x))
            (ebc::dupx new-x)
        )]
        [(ebc::swapx? node) (let ([x (ebc::swapx-x node)])
            (define new-x (if (hole? x) (list-ref assignment (hole-id x)) x))
            (ebc::swapx new-x)
        )]
        [(ebc::logx? node) (let ([x (ebc::logx-x node)])
            (define new-x (if (hole? x) (list-ref assignment (hole-id x)) x))
            (ebc::logx new-x)
        )]
        [(ebc::invalid? node) (let ([x (ebc::invalid-x node)])
            (define new-x (if (hole? x) (list-ref assignment (hole-id x)) x))
            (ebc::invalid new-x)
        )]
        [(hole? node) (list-ref assignment (hole-id node))] ; assign to hole
        [else ((struct-constructor node))] ; direct copy
    )
)