#lang graphics-engine

(require racket/class
         racket/gui/base)

#:on-key-press 'escape (send this quit)
#:clear-color green
#:on-start (λ (_ canvas) (send canvas set-cursor (make-object cursor% 'blank)))
#:on-draw (λ _ (clear) (swap-buffers))
