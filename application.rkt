#lang racket/base

(require graphics-engine/canvas
         graphics-engine/private
         opengl
         racket/class
         racket/gui/base
         racket/match
         racket/stxparam
         (for-syntax racket/base
                     syntax/transformer))

(provide (all-defined-out))

(struct application (frame canvas on-start on-draw draw0-args)
  #:transparent
  #:name gfx:application
  #:constructor-name application)

(define (run app)
  (match-define (gfx:application frame canvas on-start on-draw draw0-args) app)
  (thread
   (λ ()
     (define (info msg . args)
       (when (get-field verbose? canvas)
         (displayln (format "application: ~a" (apply format msg args)))))

     (info "starting")
     (on-start frame canvas)

     (send frame show #t)
     (send canvas focus)
     (collect-garbage)

     (parameterize ([current-canvas canvas])
       (let loop ([state draw0-args])
         (collect-garbage 'incremental)
         (define new-state (call-with-values (λ () (apply on-draw state)) list))
         (unless (get-field done? canvas) (loop new-state))))

     (info "exiting")

     (exit))))
