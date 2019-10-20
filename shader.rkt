#lang racket/base

(require ffi/vector
         opengl
         syntax/parse/define
         (for-syntax racket/base
                     racket/function
                     racket/syntax
                     syntax/strip-context))

(provide (all-defined-out))

(struct shader (parsed printed >port-constructor)
  #:transparent
  #:name gfx:shader
  #:constructor-name make-shader)

(define-syntax-parser define-shader
  [(_ name:id form ...)
   #:with source-mod (format-id #'name "~a-source" #'name)
   #:with name->port (format-id #'name "~a->port"  #'name)
   (replace-context
    this-syntax
    #'(begin
        (module source-mod glsl form ...)
        (define name (let ()
                       (local-require 'source-mod)
                       (make-shader parsed printed ->port)))
        (define (name->port) ((shader->port-constructor name)))))])
