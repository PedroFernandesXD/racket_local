#lang racket

(require db)
(require racket/date)

(provide soma-dados
         verificar
         file-csv
         inserir-valor)
         

(define (conectar-banco-dados)
  (postgresql-connect #:user "postgres"
                      #:port 5432
                      #:server "localhost"
                      #:database "trabalho"
                      #:password "12345"))


(define string-deleta-tabela "DROP TABLE trab.tabela_consumo")
  
(define string-criado-tabela "CREATE TABLE trab.tabela_consumo(
                              valor integer,
                              tempo timestamp)")

(define string-bkp-tabela "CREATE TABLE trab.tabela_consumo_bkp(
                             valor integer,
                             tempo timestamp)")

(define string-bkp-dados "INSERT INTO trab.tabela_consumo_bkp SELECT * FROM trab.tabela_consumo")


(define string-input-dados "INSERT INTO trab.tabela_consumo(valor,tempo) VALUES (1, 'now')")
(define string-deleta-dados-tabela "DELETE FROM trab.tabela_consumo")


(define (inserir-valor)
    (query-exec (conectar-banco-dados) string-input-dados)
  (disconnect (conectar-banco-dados)))


(define (deletar-tabela)
  (query-exec (conectar-banco-dados) string-deleta-tabela)
  (disconnect (conectar-banco-dados))
  (display "Tabela deletada."))

(define (criar-tabela)
  (query-exec (conectar-banco-dados) string-criado-tabela)
  (query-exec (conectar-banco-dados) string-bkp-tabela)
  (disconnect (conectar-banco-dados))
  (display "Tabela Criada."))


(define (deletar-dados-tabela)
  (query-exec (conectar-banco-dados) string-deleta-dados-tabela)
  (disconnect (conectar-banco-dados))
  (display "Dados deletados."))

(define (soma-dados)
  (define soma (query-value (conectar-banco-dados) "SELECT sum(valor) FROM trab.tabela_consumo"))
  (disconnect (conectar-banco-dados))
  (if (sql-null? soma)
      "0"
      (format "~a" soma)))


(define (tempo)
  (let ([h (list (car (cdr (cdr (cdr (vector->list (struct->vector (current-date)))))))
                 (cadr (cdr (vector->list (struct->vector (current-date))))))])
    (if (and (zero? (car h)) (zero? (cadr h)))
        #t
        #f)))

(define xtem #t)

(define (verificar)
  (if (tempo)
      (if xtem
          (begin
            (bkp)
            (deletar-dados-tabela)
            (set! xtem #f))
          #f)
      (set! xtem #t)))


(define (bkp)
  (query-exec (conectar-banco-dados) string-bkp-dados)
  (disconnect (conectar-banco-dados)))

(define tabela-bkp "trab.tabela_consumo_bkp")
(define tabela-c "trab.tabela_consumo")
(define string-csv "")

(define (file-csv x)
  (if (equal? x "tabela-c")
      (begin
        (set! string-csv (string-append "COPY (SELECT * FROM " tabela-c ") TO 'C:/temp/atual.csv' DELIMITER ';' CSV HEADER"))
        (query-exec (conectar-banco-dados) string-csv)
        (disconnect (conectar-banco-dados)))
      #f)
  (if (equal? x "tabela-bkp")
       (begin
        (set! string-csv (string-append "COPY (SELECT * FROM " tabela-bkp ") TO 'C:/temp/geral.csv' DELIMITER ';' CSV HEADER"))
        (query-exec (conectar-banco-dados) string-csv)
        (disconnect (conectar-banco-dados)))
        #f))
  
