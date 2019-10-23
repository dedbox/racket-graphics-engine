#lang graphics-engine

(require glm
         opengl)

#:legacy? #t
#:on-key-press (μ ('escape) (quit))

(define vertices
  (mat #:rows 2
       -1 -1
        1 -1
        0  1))

(define attr #f)

#:on-start
(λ ()
  (set! attr (vertex-attribute 0 2 GL_FLOAT GL_ARRAY_BUFFER GL_STATIC_DRAW
                               (mat->f32vector vertices))))

#:on-draw
(λ _
  (clear)

  (enable-vertex-attribute attr)
  (glDrawArrays GL_TRIANGLES 0 (mat-num-cols vertices))
  (disable-vertex-attribute attr)

  (swap-buffers))
