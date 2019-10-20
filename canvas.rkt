#lang racket/base

(require ffi/vector
         glm
         graphics-engine/private
         opengl
         racket/class
         racket/gui/base
         (for-syntax racket/base
                     syntax/strip-context))

(provide (all-defined-out))

(define-the-thing the-canvas current-canvas)

(define-syntax-rule (GL> body ...)
  (send the-canvas with-gl-context (λ () body ...)))

(define opengl-canvas%
  (class canvas%
    (init-field [legacy?  #f]
                [verbose? #f]
                [version  #f]
                [clear-color (vec3)])
    (inherit with-gl-context)

    (define/public (info msg . args)
      (when verbose?
        (displayln (format "canvas: ~a" (apply format msg args)))))

    (define-syntax-rule (GL>> body ...)
      (with-gl-context (λ () body ...)))

    (define config (new gl-config%))

    (define-syntax-rule (send-config/info name expr)
      (let ([val expr]) (info "~a ~a" 'name val) (send config name val)))

    (send-config/info set-double-buffered #t)
    ;; (send-config/info set-depth-size      24)
    ;; (send-config/info set-stencil-size     0)
    ;; (send-config/info set-multisample-size 0)
    (send-config/info set-legacy? legacy?)

    (super-new [style '(gl no-autoclear)]
               [gl-config config])

    (GL>>
      (info "detected OpenGL version ~a" (gl-version))
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

      ;; (glEnable GL_DEPTH_TEST)
      ;; (info "depth test enabled")

      ;; (glEnable GL_CULL_FACE)
      ;; (info "face culling enabled")

      (apply glClearColor (vec->list clear-color))
      ;; (glClearDepth 1.0)
      )

    (define/override (on-size width height)
      (info "resizing to ~ax~a" width height)
      (info "new aspect ratio is ~a" (/ width height))
      (GL>> (glViewport 0 0 width height)))

    (define/override (on-char event)
      (info "unhandled key: ~v ~v ~v ~v ~v ~v ~v"
            (send event get-key-code)
            (send event get-key-release-code)
            (key-mods event)
            (send event get-x)
            (send event get-y)
            (send event get-time-stamp)
            (send event get-control+meta-is-altgr))
      (super on-char event))

    (define/override (on-event event)
      (info "unhandled mouse: ~v ~v ~v ~v ~v ~v"
            (send event get-event-type)
            (send event get-x)
            (send event get-y)
            (mouse-buttons event)
            (key-mods event)
            (send event get-time-stamp))
      (super on-char event))))

(define (key-mods event)
  (apply append
         (if (send event get-shift-down) '(shift) null)
         (if (send event get-control-down) '(control) null)
         (if (send event get-meta-down) '(meta) null)
         (if (send event  get-alt-down) '(alt)  null)
         (if (send event get-caps-down) '(caps) null)
         (if (send event get-mod3-down) '(mod3) null)
         (if (send event get-mod4-down) '(mod4) null)
         (if (send event get-mod5-down) '(mod5) null)))

(define (mouse-buttons event)
  (apply append
         (if (send event   get-left-down) '(left)   null)
         (if (send event get-middle-down) '(middle) null)
         (if (send event  get-right-down) '(right)  null)))

(define (clear)
  (glClear GL_COLOR_BUFFER_BIT))

(define (swap-buffers)
  (send the-canvas swap-gl-buffers))
