#lang rosette
(require "../sentinel/utils.rkt")

; ================================
; this tests the commandline utils
; ================================

(define-values (sp out in err) (start-cmd "ls" ($ "-l")))
(printf "out:\n~a\n" (port->string out))
(printf "err:\n~a\n" (port->string err))

(close-cmd sp out in err)