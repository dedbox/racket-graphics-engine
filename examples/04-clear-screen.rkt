#lang graphics-engine

#:clear-color blue
#:on-key-press (μ ('escape) (quit))
#:on-draw (λ _ (clear) (swap-buffers))
