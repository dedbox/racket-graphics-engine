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

(define-the-things
  [the-frame       current-frame]
  [the-application current-application]
  [the-process     current-process])

(struct application (frame canvas do-start do-draw do-idle)
  #:name gfx:application
  #:constructor-name application)

(struct process (quit-sema)
  #:name gfx:process
  #:constructor-name process)

(define (quit)
  (semaphore-post (process-quit-sema the-process)))

(define (run app)
  (match-define (gfx:application frame canvas do-start do-draw do-idle) app)

  (define (info msg . args)
    (when (get-field verbose? canvas)
      (displayln (format "application: ~a" (apply format msg args)))))

  (parameterize ([current-frame  frame ]
                 [current-canvas canvas])
    (info "starting")
    (when do-start (GL> (do-start)))

    (send frame show #t)
    (send canvas focus)

    (define quit-sema (make-semaphore))
    (thread (λ () (semaphore-wait quit-sema) (info "exiting") (exit)))

    (when do-idle
      (thread
       (λ ()
         (let loop ([state null])
           (sync (system-idle-evt))
           (loop (call-with-values (λ () (GL> (apply do-idle state))) list))))))

    (when do-draw
      (thread
       (λ ()
         (collect-garbage)
         (let loop ([state null])
           (collect-garbage 'incremental)
           (sleep)
           (loop (call-with-values (λ () (GL> (apply do-draw state))) list))))))

    (process quit-sema)))
