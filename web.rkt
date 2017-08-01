#lang racket

(require "main.rkt"
         "banco.rkt"
         web-server/servlet
         web-server/templates
         json)


(define maxr "100")

(define lei (soma-dados))

(define st "ligado")

(get "/new" (lambda (req)
              (set! maxr (params req 'maximo))
              maxr
              (include-template "new.html")
              ))


(get "/leitura" (lambda (req)
                    (if (equal? (params req 'cod) "txj7")
                        (begin
                          (inserir-valor)
                          (set! lei (soma-dados))
                          (if (>= (string->number lei) (string->number maxr))                              
                              (set! st "desligado")
                              (set! st "ligado")))
                        "Codigo Invalido")
                    (include-template "leitura.html")))
                    

(get "/hi" (lambda (req)
  (string-append "Hello, " (params req 'name))))

(get "/" (lambda ()
           (verificar)
           (set! lei (soma-dados))
           (include-template "index.html")))


(define csvf "")

(get "/csv" (lambda (req)
              (define csv-file (params req 'tabela))
              (file-csv csv-file)
              (cond [(equal? csv-file "tabela-c")
                     (set! csvf "Tabela Atual Criada em C:/temp/")]
                     [(equal? csv-file "tabela-bkp")
                      (set! csvf "Tabela Geral Criada em C:/temp/")]
                     [else
                      (set! csvf "")])
              (include-template "csv.html")))
              


(run #:listen-ip #f)
