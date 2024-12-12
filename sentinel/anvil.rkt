#lang rosette
(require json net/http-client)
(require "./utils.rkt")
(provide (all-defined-out))

; addr (str): server address | port (int): anvil port | uri (str): anvil uri
(struct serv (addr port uri) #:mutable #:transparent #:reflection-name 'anvil-server)

; encode hasheq object into string
(define (rpc-cmd method params id)
    (jsexpr->string (make-hash (list
        (cons 'jsonrpc "2.0")
        (cons 'method method)
        (cons 'params params)
        (cons 'id id)
    )))
)

; generic remote procedural call for anvil server
; return: status in bool, result in json
(define (rpc sv data)
    (define-values (status headers in) (http-sendrecv
        (serv-addr sv) (serv-uri sv)
        #:port (serv-port sv)
        #:version "1.1"
        #:method "POST"
        #:headers (list "Content-Type: application/json")
        #:data data
    ))
    (define ok? (equal? #"HTTP/1.1 200 OK" status))
    (define body (string->jsexpr (port->string in)))
    (close-input-port in)
    (values ok? body)
)

(define (unwrap ok? res)
    (if ok? 
        (hash-ref res 'result)
        (error 'unwrap (format "invalid status, response: ~a" res))
    )
)

; ==================================== ;
; ==== anvil's eth json rpc calls ==== ;
; ==================================== ;
; ref: https://ethereum.org/en/developers/docs/apis/json-rpc/

; return (int): block number
(define (eth_blockNumber sv [id 67] #:raw? [raw? #f]) 
    (define-values (ok? res) (rpc sv (rpc-cmd "eth_blockNumber" null id)))
    (if raw? (values ok? res) (hexstr->number (unwrap ok? res)))
)

; n (int): block number | fo? (bool): return full object (#t) or tx hashes (#f)
; return (json)
(define (eth_getBlockByNumber sv n [fo? #t] [id 67] #:raw? [raw? #f]) 
    (define-values (ok? res) (rpc sv (rpc-cmd "eth_getBlockByNumber" (list (format "0x~x" n) fo?) id)))
    (if raw? (values ok? res) (unwrap ok? res))
)

; mine a single block
; return (int): 0x0
(define (evm_mine sv [id 67] #:raw? [raw? #f])
    (define-values (ok? res) (rpc sv (rpc-cmd "evm_mine" null id)))
    (if raw? (values ok? res) (hexstr->number (unwrap ok? res)))
)

; FIXME: this method currently doesn't work
; return (hexstr): tx hash
; (define (eth_sendTransaction sv tx [id 67] #:raw? [raw? #f])
;     ; (define-values (ok? res) (rpc sv (rpc-cmd "eth_sendTransaction" (list tx) id)))
;     (define tx0 (make-hash (list
;         (cons 'from (hash-ref tx 'from))
;         (cons 'to (hash-ref tx 'to))
;         (cons 'gas (hash-ref tx 'gas))
;         (cons 'gasPrice (hash-ref tx 'gasPrice))
;         (cons 'value (hash-ref tx 'value))
;         (cons 'input (hash-ref tx 'input))
;     )))
;     (define-values (ok? res) (rpc sv (rpc-cmd "eth_sendTransaction" (list tx0) id)))
;     (if raw? (values ok? res) (unwrap ok? res))
; )

; return (hexstr): tx hash
(define (eth_sendUnsignedTransaction sv tx [id 67] #:raw? [raw? #f])
    (define tx0 (make-hash (list
        (cons 'from (hash-ref tx 'from))
        (cons 'to (hash-ref tx 'to))
        (cons 'gas (hash-ref tx 'gas))
        (cons 'gasPrice (hash-ref tx 'gasPrice))
        (cons 'value (hash-ref tx 'value))
        (cons 'input (hash-ref tx 'input))
    )))
    (define-values (ok? res) (rpc sv (rpc-cmd "eth_sendUnsignedTransaction" (list tx0) id)))
    (if raw? (values ok? res) (unwrap ok? res))
)

; addr (hexstr)
; return (int): balance
(define (eth_getBalance sv addr [bn "latest"] [id 67] #:raw? [raw? #f])
    (define-values (ok? res) (rpc sv (rpc-cmd "eth_getBalance" (list addr bn) id)))
    (if raw? (values ok? res) (hexstr->number (unwrap ok? res)))
)

; (new method) reset server's block number
; bn (int): block number
; return (null)
(define (anvil_resetBlockNumber sv bn [id 67] #:raw? [raw? #f])
    ; the original method takes blockNumber as integer, not hexstr
    (define-values (ok? res) (rpc sv (rpc-cmd "anvil_reset" (list 
        (make-hash (list (cons 'forking (make-hash (list (cons 'blockNumber bn))))))) id)))
    (if raw? (values ok? res) (unwrap ok? res))
)

; on? (bool): whether to enable automine or not
; return (null)
(define (evm_setAutomine sv on? [id 67] #:raw? [raw? #f])
    (define-values (ok? res) (rpc sv (rpc-cmd "evm_setAutomine" (list on?) id)))
    (if raw? (values ok? res) (unwrap ok? res))
)

; hash (hexstr): tx hash
; return (json)
(define (eth_getTransactionReceipt sv hash [id 67] #:raw? [raw? #f])
    (define-values (ok? res) (rpc sv (rpc-cmd "eth_getTransactionReceipt" (list hash) id)))
    (if raw? (values ok? res) (unwrap ok? res))
)

; addr (hexstr) | bal (int)
; return (null)
(define (anvil_setBalance sv addr bal [id 67] #:raw? [raw? #f])
    (define-values (ok? res) (rpc sv (rpc-cmd "anvil_setBalance" (list addr (number->hexstr bal 0)) id)))
    (if raw? (values ok? res) (unwrap ok? res))
)