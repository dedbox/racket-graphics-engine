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

(define current-frame (make-parameter #f))

(define-syntax the-frame (make-variable-like-transformer #'(current-frame)))

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
     (parameterize ([current-frame  frame ]
                    [current-canvas canvas])
       (info "starting")
       (send canvas with-gl-context (λ () (on-start)))
       (send frame show #t)
       (send canvas focus)
       (collect-garbage)
       (let loop ([state draw0-args])
         (collect-garbage 'incremental)
         (define new-state
           (call-with-values (λ () (GL> (apply on-draw state))) list))
         (unless (get-field done? canvas) (loop new-state))))
     (info "exiting")
     (exit))))
