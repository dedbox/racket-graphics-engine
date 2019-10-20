#lang racket/base

(require graphics-engine/shader
         graphics-engine/vertex
         opengl
         opengl/util
         racket/function
         racket/match
         syntax/parse/define)

(provide (all-defined-out))

(struct drawable (attributes program uniforms locations)
  #:name gfx:drawable
  #:constructor-name make-drawable)

(define-simple-macro
  (drawable vertex-shader:expr
            fragment-shader:expr
            (~alt (~seq #:attribute index size type target usage data)
                  (~seq #:uniform uniform:id name:id)) ...)
  (let ()
    (define attributes
      (list (vertex-attribute index size type target usage data) ...))
    (define shaders
      (list (load-shader ((shader->port-constructor   vertex-shader))   GL_VERTEX_SHADER)
            (load-shader ((shader->port-constructor fragment-shader)) GL_FRAGMENT_SHADER)))
    (define program (apply create-program shaders))
    (define uniforms (list uniform ...))
    (define locations (map (curry glGetUniformLocation program)
                           (map symbol->string '(name ...))))
    (glUseProgram program)
    (make-drawable attributes program uniforms locations)))

(define (draw obj count mode . args)
  (match-define (gfx:drawable attributes program uniforms locations) obj)
  (for ([ uniform (in-list uniforms )]
        [location (in-list locations)]
        [     arg (in-list args     )])
    (uniform location arg))
  (with-vertex-attributes attributes (glDrawArrays mode 0 count)))
