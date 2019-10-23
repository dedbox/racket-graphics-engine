#lang graphics-engine

(require ffi/vector
         opengl)

#:legacy? #t
#:on-key-press (μ ('escape) (quit))

(define data
  (apply f32vector
         (apply append
                (for*/list ([y (in-range -0.5 0.51 0.2)]
                            [x (in-range -0.5 0.51 0.2)])
                  (list x y)))))

(define vbo #f)

#:on-start
(λ ()
  (glPointSize 15.0)
  (set! vbo (make-vbo GL_ARRAY_BUFFER data GL_STATIC_DRAW)))

#:on-draw
(λ _
  (clear)

  (glEnableVertexAttribArray 0)
  (bind-vbo vbo)

  (glVertexAttribPointer 0 2 GL_FLOAT #f 0 0)
  (glDrawArrays GL_POINTS 0 (quotient (f32vector-length data) 2))
  (glDisableVertexAttribArray 0)

  (swap-buffers))
