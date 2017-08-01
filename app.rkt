#lang racket

(require "main.rkt"
         "banco.rkt"
         web-server/servlet
         web-server/tempates
         json)


(get "/hi/:name" (lambda (req)
  (string-append "Hello, " (params req 'name) "!")))
