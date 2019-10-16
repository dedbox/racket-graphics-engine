
#lang graphics-engine

(require racket/class
         racket/gui/base)

#:clear-color green
#:on-key-press (λ ('escape) (quit))
#:on-start (λ () (send the-canvas set-cursor (make-object cursor% 'blank)))
#:on-draw (λ _ (clear) (swap-buffers))
