#lang graphics-engine

(require ffi/vector
         opengl)

#:legacy? #t
#:on-key-press (μ ('escape) (quit))

(define vbo #f)

#:on-start
(λ ()
  (define data (f32vector 0.0 0.0))
  (set! vbo (u32vector-ref (glGenBuffers 1) 0))
  (glBindBuffer GL_ARRAY_BUFFER vbo)
  (glBufferData GL_ARRAY_BUFFER (gl-vector-sizeof data) data GL_STATIC_DRAW))

#:on-draw
(λ _
  (clear)

  (glEnableVertexAttribArray 0)
  (glBindBuffer GL_ARRAY_BUFFER vbo)
  (glVertexAttribPointer 0 2 GL_FLOAT #f 0 0)
  (glDrawArrays GL_POINTS 0 1)
  (glDisableVertexAttribArray 0)

  (swap-buffers))
