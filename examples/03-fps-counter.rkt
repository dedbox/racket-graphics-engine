#lang graphics-engine

(require racket/class
         racket/match)

(define rate-limit 0)

#:verbose?   #t
#:min-width  64
#:min-height 64
#:on-key-press 'escape (send this quit)

#:canvas (class opengl-canvas%
           (super-new)
           (inherit quit)
           (define/override (on-char event)
             (match* ((send event get-key-code)
                      (send event get-key-release-code))
               [('release _    ) (void)]
               [(_        _    ) (super on-char event)])))

#:on-draw

(λ ([ msecs (current-inexact-milliseconds)]
    [Δmsecs 0]
    [ ticks 0])

  ;;; pretend to draw stuff
  (when (positive? rate-limit)
    (sync (alarm-evt (+ (current-inexact-milliseconds) (/ 1000.0 rate-limit)))))

  ;;; return 1 value per argument
  (cond [(>= Δmsecs 1000) (printf "~a fps\n" ticks)
                          (values (current-inexact-milliseconds) 0 0)]
        [else (define new-msecs (current-inexact-milliseconds))
              (values new-msecs (+ Δmsecs (- new-msecs msecs)) (add1 ticks))]))
