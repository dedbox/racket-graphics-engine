#lang graphics-engine

(require ffi/vector
         glm
         opengl
         opengl/util)

#:on-key-press (μ ('escape) (quit))

(define vertices (mat #:rows 2
                      ;; triangle 1
                      -0.90 -0.90
                       0.85 -0.90
                      -0.90  0.85
                      ;; triangle 2
                       0.90 -0.85
                       0.90  0.90
                      -0.85  0.90))

(define-shader vertex-shader
  (#%version 330 core)
  (layout ([location 0]) in vec4 vPosition)
  (define (main) : void (set! gl_Position vPosition)))

(define-shader fragment-shader
  (#%version 330 core)
  (layout ([location 0]) out vec4 color)
  (define (main) : void (set! color (vec4 0 0 1 1))))

(define vao #f)
(define program #f)

#:on-start
(λ ()
  (define data (mat->f32vector vertices))

  (define vbo (u32vector-ref (glGenBuffers 1) 0))
  (glBindBuffer GL_ARRAY_BUFFER vbo)
  (glBufferData GL_ARRAY_BUFFER (gl-vector-sizeof data) data GL_STATIC_DRAW)
  (glBindBuffer GL_ARRAY_BUFFER 0)

  (set! vao (u32vector-ref (glGenVertexArrays 1) 0))
  (glBindVertexArray vao)

  (glBindBuffer GL_ARRAY_BUFFER vbo)
  (glVertexAttribPointer 0 2 GL_FLOAT #f 0 0)
  (glEnableVertexAttribArray 0)

  (glBindVertexArray 0)
  (glDisableVertexAttribArray 0)
  (glBindBuffer GL_ARRAY_BUFFER 0)

  (set! program
    (create-program
     (load-shader   (vertex-shader->port)   GL_VERTEX_SHADER)
     (load-shader (fragment-shader->port) GL_FRAGMENT_SHADER)))
  (glUseProgram program))

#:on-draw
(λ _
  (clear)

  (glUseProgram program)
  (glBindVertexArray vao)

  (glDrawArrays GL_TRIANGLES 0 (mat-num-cols vertices))

  (glUseProgram 0)
  (glBindVertexArray 0)

  (swap-buffers))
