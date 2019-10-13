#lang racket/base

(require racket/class)

(provide (all-defined-out))

(define-syntax-rule (GL>> canvas body ...)
  (send canvas with-gl-context (λ () body ...)))
