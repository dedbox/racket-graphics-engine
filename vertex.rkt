#lang racket/base

(require ffi/vector
         opengl
         racket/match)

(provide (all-defined-out))

;;; ----------------------------------------------------------------------------

(struct vertex-buffer (vbo))

(define (make-vbo target data usage)
  (define vbo (u32vector-ref (glGenBuffers 1) 0))
  (glBindBuffer target vbo)
  (glBufferData target (gl-vector-sizeof data) data usage)
  vbo)

(define (bind-vbo vbo)
  (glBindBuffer GL_ARRAY_BUFFER vbo))

;;; ----------------------------------------------------------------------------

(struct vertex-attribute (vbo index size type)
  #:name gfx:vertex-attribute
  #:constructor-name make-vertex-attribute)

(define (vertex-attribute index size data
                          #:type   [type   GL_FLOAT]
                          #:target [target GL_ARRAY_BUFFER]
                          #:usage  [usage  GL_STATIC_DRAW])
  (make-vertex-attribute (make-vbo target data usage) index size type))

(define (enable-vertex-attribute attr)
  (match-define (gfx:vertex-attribute vbo index size type) attr)
  (glEnableVertexAttribArray index)
  (bind-vbo vbo)
  (glVertexAttribPointer index size type #f 0 0))

(define (disable-vertex-attribute attr)
  (glDisableVertexAttribArray (vertex-attribute-index attr)))

(define-syntax-rule (with-vertex-attribute attr-expr body ...)
  (let ([attr attr-expr])
    (enable-vertex-attribute attr) body ... (disable-vertex-attribute attr)))

(define-syntax-rule (with-vertex-attributes attrs-expr body ...)
  (let ([attrs attrs-expr])
    (for-each enable-vertex-attribute attrs)
    body ...
    (for-each disable-vertex-attribute attrs)))

;; ;;; ----------------------------------------------------------------------------

;; (struct uniform (type name)
;;   #:name gfx:uniform
;;   #:constructor-name make-uniform)

;; (define (uniform name type . ))
