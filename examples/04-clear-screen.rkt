#lang graphics-engine

#:clear-color blue
#:on-key-press (λ ('escape) (quit))
#:on-draw (λ _ (clear) (swap-buffers))
