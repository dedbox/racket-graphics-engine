#lang graphics-engine

(require racket/class)

#:on-key-press 'escape (send this quit)
#:clear-color blue
#:on-draw (λ _ (clear) (swap-buffers))
