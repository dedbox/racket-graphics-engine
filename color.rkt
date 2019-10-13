#lang racket/base

(require glm
         graphics-engine/vector
         racket/format
         (only-in racket/math exact-round))

(provide (all-defined-out))

(define-syntax-rule (define-colors [name (R G B)] ...)
  (begin (define name ($4 R G B 1)) ...))

(define-colors
  ;;        R G B
  [white   (1 1 1)]
  [red     (1 0 0)]
  [green   (0 1 0)]
  [blue    (0 0 1)]
  [cyan    (0 1 1)]
  [magenta (1 0 1)]
  [yellow  (1 1 0)]
  [black   (0 0 0)])

(define (html-color color)
  (apply format "#~a~a~a"
         (for/list ([x (in-$ color)])
           (~r (exact-round (* x 255))
               #:base 16 #:precision 0 #:min-width 2 #:pad-string "0"))))

(define (rgb hex)
  ($4 (bitwise-and #xFF (arithmetic-shift hex -16))
      (bitwise-and #xFF (arithmetic-shift hex  -8))
      (bitwise-and #xFF hex)
      1))

(define (rgba hex)
  ($4 (bitwise-and #xFF (arithmetic-shift hex -24))
      (bitwise-and #xFF (arithmetic-shift hex -16))
      (bitwise-and #xFF (arithmetic-shift hex  -8))
      (bitwise-and #xFF hex)))

(define (argb hex)
  ($4 (bitwise-and #xFF (arithmetic-shift hex -16))
      (bitwise-and #xFF (arithmetic-shift hex  -8))
      (bitwise-and #xFF hex)
      (bitwise-and #xFF (arithmetic-shift hex -24))))
