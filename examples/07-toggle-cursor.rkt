#lang graphics-engine

(require racket/class
         racket/gui/base)

(define gui-mode? #t)

(define (cursor)
  (make-object cursor% (if gui-mode? 'arrow 'blank)))

(define center (^ 400 300))
(define position (^ -1 -1))

(define-syntax-rule (define-setters [name var a b val-expr] ...)
  (begin (define (name a b) (set! var val-expr)) ...))

(define-setters
  ;; name        var      a     b      val-expr
  [set-center!   center   width height (^/ (^ width height) 2)]
  [set-position! position x     y      (^ x y)])

(define-syntax-rule (define-pointer-warpers [name var] ...)
  (begin (define (name) (send/apply the-canvas warp-pointer (^list var))) ...))

(define-pointer-warpers
  ;; name     var
  [recenter   center  ]
  [reposition position])

#:verbose? #t
#:on-key-press (λ (#\q '(meta)) (quit))
#:on-key-press (λ ('escape)
                 (set! gui-mode? (not gui-mode?))
                 (send the-canvas set-cursor (cursor))
                 ((if gui-mode? reposition recenter)))
#:on-mouse-motion (λ (x y) (if gui-mode? (set-position! x y) (recenter)))
#:on-size (λ (width height) (set-center! width height))
#:on-draw (λ _ (clear) (swap-buffers))
