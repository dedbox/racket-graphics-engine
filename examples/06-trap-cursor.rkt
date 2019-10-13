#lang graphics-engine

(require racket/class
         racket/gui/base)

#:canvas (class opengl-canvas%
           (super-new)
           (inherit warp-pointer)
           (field [mid-x 400] [mid-y 300])

           (define/override (on-size width height)
             (set! mid-x (/  width 2))
             (set! mid-y (/ height 2))
             (warp-pointer-to-center)
             (super on-size width height))

           (define/public (pointer-offset x y)
             (values (- x mid-x) (- y mid-y)))

           (define/public (warp-pointer-to-center)
             (warp-pointer mid-x mid-y)))

#:on-key-press 'escape (send this quit)

#:on-mouse-motion (x y) (let-values ([(Δx Δy) (send this pointer-offset x y)])
                          (unless (and (zero? Δx)
                                       (zero? Δy))
                            (printf "Δx=~a Δy=~a\n" Δx Δy)
                            (send this warp-pointer-to-center)))

#:on-draw (λ _ (clear) (swap-buffers))
