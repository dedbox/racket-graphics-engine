#lang racket/base

(require ffi/vector
         glm)

(provide (all-defined-out))

(define-values (^ ^+ ^- ^* ^/ ^? ^list in-^)
  (values ivec ivec+ ivec- ivec* ivec/ ivec? ivec->list in-ivec))

(define-values (^1 ^1?) (values ivec1 ivec1?))
(define-values (^2 ^2?) (values ivec2 ivec2?))
(define-values (^3 ^3?) (values ivec3 ivec3?))
(define-values (^4 ^4?) (values ivec4 ivec4?))

(define-values ($ $+ $- $* $/ $? $list in-$)
  (values vec vec+ vec- vec* vec/ vec? vec->list in-vec))

(define ($f32vector . args)
  (vec->f32vector (apply vec args)))

(define-values ($1 $1?) (values vec1 vec1?))
(define-values ($2 $2?) (values vec2 vec2?))
(define-values ($3 $3?) (values vec3 vec3?))
(define-values ($4 $4?) (values vec4 vec4?))
