#lang graphics-engine

(require glm)

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
  (uniform mat4 world)
  (define (main) (define gl_Position (* world (vec4 position 0 1)))))

(define-shader fragment-shader
  (version 130)
  (out fragColor)
  (define (main) (define fragColor (vec4 1 0 0 1))))

(define obj #f)

#:on-start
(λ ()
  (define data (mat->f32vector vertices))
  (set! obj (drawable vertex-shader fragment-shader
                      (vertex-attribute "position" 2 data)
                      (uniform "world" glUniformMatrix4fv))))

#:on-draw
(λ ([scale 0.0])
  (clear)

  (define world (mat4 1 0 0 (sin scale)
                      0 1 0 0
                      0 0 1 0
                      0 0 0 1))
  (draw obj 3 GL_TRIANGLES (mat->f32vector world))

  (swap-buffers)
  (+ scale 0.01))
