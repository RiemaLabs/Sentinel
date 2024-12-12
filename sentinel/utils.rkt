#lang rosette
(require 
    (prefix-in ext:: "./extensions.rkt")
)
(provide (all-defined-out))

; ================================ ;
; ======== symbolic utils ======== ;
; ================================ ;

; id: symbol, type: symbol
(define (fresh-symbolic id type)
    (cond
        [(equal? 'int type)
            (constant (list id) integer?)
        ]
        [(equal? 'bool type)
            (constant (list id) boolean?)
        ]
        [else (error "unknown symbolic type, got: ~a" type)]
    )
)

(define (fresh-symbolic* id type)
    (cond
        [(equal? 'int type)
                (constant (list id (ext::index!)) integer?)
        ]
        [(equal? 'bool type)
                (constant (list id (ext::index!)) boolean?)
        ]
        [else (error "unknown symbolic type, got: ~a" type)]
    )
)

; ==================================================================== ;
; ======== association list (unmutable with symbolic support) ======== ;
; ==================================================================== ;
; with primitive collection
; assoc? | lst: list | kc (key contract): lambda(?->bool) | vc (value contract): lambda(?-> bool)
(define (assocl? lst #:kc [kc (λ (x) #t)] #:vc [vc (λ (x) #t)])
    (if (list? lst)
        (apply && (for/list ([p lst])
            (if (pair? p)
                (&& (kc (car p)) (vc (cdr p)))
                #f
            )
        ))
        #f
    )
)

(define (assocl-ref lst key)
    (if (assocl-has-key? lst key)
        (let ([p (car lst)])
            (if (equal? key (car p))
                (cdr p) ; found
                (assocl-ref (cdr lst) key) ; not found, move next
            )
        )
        (error 'assocl-ref (format "cannot find key: ~a" key))
    )
)

(define (assocl-has-key? lst key)
    (if (null? lst)
        #f ; exhausted
        (let ([p (car lst)])
            (if (equal? key (car p))
                #t ; found
                (assocl-has-key? (cdr lst) key) ; not found, move next
            )
        )
    )
)

; ================================================================== ;
; ======== association list (mutable with symbolic support) ======== ;
; ================================================================== ;

; create a mutable struct so that we can update it like hash
; instead of creating a new copy every time (though down here it's still creating a new copy)
; it's like a box now which is mutable
(struct asl (vs) #:mutable #:transparent #:reflection-name 'asl)
(define (make-asl [vs null]) (asl vs))

(define (asl-ref lst key)
    (if (asl-has-key? lst key)
        (let ([p (car (asl-vs lst))])
            (if (equal? key (car p))
                (cdr p) ; found
                (asl-ref (asl (cdr (asl-vs lst))) key) ; not found, move next
            )
        )
        (error 'asl-ref (format "cannot find key: ~a" key))
    )
)

(define (asl-has-key? lst key)
    (if (null? (asl-vs lst))
        #f ; exhausted
        (let ([p (car (asl-vs lst))])
            (if (equal? key (car p))
                #t ; found
                (asl-has-key? (asl (cdr (asl-vs lst))) key) ; not found, move next
            )
        )
    )
)

; NOTE: this directly modifies the value
(define (asl-set! lst key val)
    (if (asl-has-key? lst key)
        (set-asl-vs! lst (for/list ([p (asl-vs lst)])
            (if (equal? key (car p))
                (cons key val) ; hit, update
                p ; not hit, keep
            )
        ))
        (set-asl-vs! lst (cons (cons key val) (asl-vs lst))) ; add pair directly
    )
    #t ; return true when done
)

; =============================== ;
; ======== generic utils ======== ;
; =============================== ;

; check if an element presents in a list
(define (contains? lst ele [fn equal?])
    (if (null? lst)
        #f
        (if (fn ele (car lst))
            #t
            (contains? (cdr lst) ele fn)
        )
    )
)

; append a single element to the end of the list
; i.e., a reversed version of `cons`
(define (rcons lst ele) (append lst (list ele)))

(define (hexstr->number s) (string->number (string-trim (string-downcase s) "0x" #:right? #f) 16))
(define (number->hexstr n mw [prefix? #t]) 
    (if prefix? 
        (~a (format "0x~x" n) #:min-width mw #:align 'right #:left-pad-string "0")
        (~a (format "~x" n) #:min-width mw #:align 'right #:left-pad-string "0")
    )
)

; last: get the last element of a list
; drop-right: remove the last n element(s) of a list

; struct instance reflection utils
;   - these are for instance, not for struct
(define (struct-type ins) (let-values ([(t s) (struct-info ins)]) t))
(define (struct-name ins) (let ([t (struct-type ins)])
    (let-values ([(name _0 _1 _2 _3 _4 _5 _6) (struct-type-info t)]) name)))
(define (struct-constructor ins) (let ([t (struct-type ins)])
    (struct-type-make-constructor t)))

; ===================================== ;
; ======== communication utils ======== ;
; ===================================== ;

; run and immediately stop a command
(define (run-cmd cmd args [force? #f])
    (define-values (sp out in err) (start-cmd cmd args))
    (close-cmd sp out in err force?)
)

; run a command
(define (start-cmd cmd args)
    (define-values (sp out in err) 
        (apply subprocess #f #f #f (find-executable-path cmd) args))
    (values sp out in err)
)

; stop a command
(define (close-cmd sp out in err [force? #f])
    (close-input-port out)
    (close-output-port in)
    (close-input-port err)
    (subprocess-kill sp force?)
)