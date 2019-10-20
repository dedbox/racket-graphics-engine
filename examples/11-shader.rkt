#lang graphics-engine

(require ffi/vector
         glm
         opengl
         opengl/util)

#:legacy?  #t
#:verbose? #t
#:on-key-press (μ ('escape) (quit))

(define vertices
  (mat #:rows 2
       -1 -1
        1 -1
        0  1))

(define-shader vertex-shader
  (version 130)
  (in vec2 position)
  (define (main) (define gl_Position (vec4 position 0 1))))

(define-shader fragment-shader
  (version 130)
  (out vec4 fragColor)
  (define (main) (define fragColor (vec4 1 0 0 1))))

(define attr #f)

#:on-start
(λ ()
  (set! attr (vertex-attribute 0 2 (mat->f32vector vertices)))
  (define shaders
    (list (load-shader   (vertex-shader->port)   GL_VERTEX_SHADER)
          (load-shader (fragment-shader->port) GL_FRAGMENT_SHADER)))
  (define program (apply create-program shaders))
  (glUseProgram program))

#:on-idle
(λ _
  (clear)

  (with-vertex-attribute attr
    (glDrawArrays GL_TRIANGLES 0 3))

  (swap-buffers))
