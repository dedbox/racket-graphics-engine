#lang graphics-engine

(require glm
         opengl
         opengl/util)

#:legacy? #t
#:on-key-press (μ ('escape) (quit))

(define vertices
  (mat #:rows 2
       -1 -1
        1 -1
        0  1))

(define-shader vertex-shader
  (version 130)
  (in vec2 position)
  (uniform float scale)
  (define (main) (define gl_Position (vec4 (* scale position) 0 1))))

(define-shader fragment-shader
  (version 130)
  (out vec4 fragColor)
  (define (main) (define fragColor (vec4 1 0 0 1))))

(define obj #f)

#:on-start
(λ ()
  (define data (mat->f32vector vertices))
  (set! obj (drawable vertex-shader fragment-shader
                      #:attribute (vertex-attribute "position" 2 data)
                      #:uniform "scale" (glUniform1f ))))

#:on-draw
(λ ([scale 0.0])
  (clear)
  (draw obj 3 GL_TRIANGLES (sin scale))
  (swap-buffers)
  (+ scale 0.01))
