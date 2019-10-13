#lang racket/base

(require ffi/vector
         glm
         graphics-engine/private
         opengl
         racket/class
         racket/gui/base)

(provide (all-defined-out))

(define UNHANDLED (string->unreadable-symbol "UNHANDLED"))

(define current-canvas (make-parameter #f))

(define opengl-canvas%
  (class canvas%

    (init-field [verbose? #f          ]
                [version  #f          ]
                [clear-color (vec3)   ]
                [mode  GL_FILL        ]
                [keys  (λ _ UNHANDLED)]
                [mouse (λ _ UNHANDLED)])

    ;; --

    (field [done? #f])

    (define/public (quit)
      (set! done? #t))

    ;; --

    (inherit with-gl-context)

    (define-syntax-rule (GL> body ...)
      (with-gl-context (λ () body ...)))

    ;; ---

    (define (info msg . args)
      (when verbose?
        (displayln (format "canvas: ~a" (apply format msg args)))))

    ;; --

    (define config (new gl-config%))

    (define-syntax-rule (send-config/info name expr)
      (let ([val expr]) (info "~a ~a" 'name val) (send config name val)))

    (send-config/info set-double-buffered #t)
    (send-config/info set-depth-size      24)
    (send-config/info set-stencil-size     0)
    (send-config/info set-multisample-size 0)
    (send-config/info set-legacy?         #f)

    (super-new [style '(gl no-autoclear)]
               [gl-config config])

    ;; --

    (GL> (info "detected OpenGL version ~a" (gl-version))
         (when version
           (info "want Opengl version ~a" version)
           (unless (gl-version-at-least? version)
             (info "aborting!")
             (exit 1)))
         (info   "vendor: ~a" (glGetString GL_VENDOR  ))
         (info "renderer: ~a" (glGetString GL_RENDERER))

         (define flags (s32vector-ref (glGetIntegerv GL_CONTEXT_FLAGS) 0))
         (if (zero? (bitwise-and flags GL_CONTEXT_FLAG_DEBUG_BIT))
             (info "debug mode not supported")
             (info "debug mode supported"))

         (glEnable GL_DEPTH_TEST)
         (info "depth test enabled")

         (glEnable GL_CULL_FACE)
         (info "face culling enabled")

         (apply glClearColor (vec->list clear-color))
         (glClearDepth 1.0))

    ;; --

    (define/override (on-size width height)
      (info "resizing to ~ax~a" width height)
      (info "new aspect ratio is ~a" (/ width height))
      (GL> (glViewport 0 0 width height)))

    (define/override (on-char event)
      (info "unhandled key: ~v ~v"
            (send event get-key-code)
            (send event get-key-release-code))
      (super on-char event))

    (define/override (on-event event)
      (info "unhandled mouse: ~v ~v ~v"
            (send event get-event-type)
            (send event get-x)
            (send event get-y))
      (super on-char event))

    ;; --

    (define/public (clear)
      (GL> (glClear (bitwise-ior GL_COLOR_BUFFER_BIT
                                 GL_DEPTH_BUFFER_BIT))))))

(define (clear [canvas (current-canvas)])
  (send canvas clear))

(define (swap-buffers [canvas (current-canvas)])
  (send canvas swap-gl-buffers))
