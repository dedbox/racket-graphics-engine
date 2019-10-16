#lang racket/base

(require racket/class
         (for-syntax racket/base
                     syntax/transformer))

(provide (all-defined-out))

(define-syntax-rule (GL>> canvas body ...)
  (send canvas with-gl-context (λ () body ...)))

(define-syntax-rule (define-the-thing the-thing-name param-name)
  (begin (define param-name (make-parameter #f))
         (define-syntax the-thing-name
           (make-variable-like-transformer #'(param-name) #'param-name))))

(define-syntax-rule (define-the-things [the-thing-name param-name] ...)
  (begin (define-the-thing the-thing-name param-name) ...))
