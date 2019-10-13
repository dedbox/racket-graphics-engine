#lang racket/base

(require graphics-engine
         racket/base
         racket/match
         syntax/parse/define
         (for-syntax racket/base
                     racket/function
                     syntax/strip-context))

(provide (all-from-out graphics-engine)
         (except-out (all-from-out racket/base) #%module-begin)
         (rename-out [module-begin #%module-begin]))

(define-syntax-parser module-begin
  #:literals (λ lambda)
  [(_ (~alt (~optional (~seq #:title          title:expr))
            (~optional (~seq #:canvas canvas-class%:expr))
            (~optional (~seq #:min-width      width:expr))
            (~optional (~seq #:min-height    height:expr))
            (~optional (~seq #:clear-color    color:expr))
            (~optional (~seq #:verbose?       info?:expr))
            (~optional (~seq #:on-start    do-start:expr))
            (~optional (~seq #:on-draw ((~or λ lambda)
                                        (~or draw-rest:id
                                             ([draw-var:id draw-arg:expr] ...))
                                        do-draw:expr ...)))
            (~seq #:on-key (key0:expr key1:expr) do-key:expr)
            (~seq #:on-key-press     press-k:expr   do-key-press:expr)
            (~seq #:on-key-release release-k:expr do-key-release:expr)
            (~seq #:on-mouse (mouse0:expr mouse-x:expr  mouse-y:expr)           do-mouse:expr)
(~optional (~seq #:on-mouse-motion         (motion-x:expr motion-y:expr) do-mouse-motion:expr))
(~optional (~seq #:on-mouse-enter          ( enter-x:expr  enter-y:expr)  do-mouse-enter:expr))
(~optional (~seq #:on-mouse-leave          ( leave-x:expr  leave-y:expr)  do-mouse-leave:expr))
(~optional (~seq #:on-mouse-press-left     ( ldown-x:expr  ldown-y:expr)  do-mouse-ldown:expr))
(~optional (~seq #:on-mouse-press-right    ( rdown-x:expr  rdown-y:expr)  do-mouse-rdown:expr))
(~optional (~seq #:on-mouse-press-middle   ( mdown-x:expr  mdown-y:expr)  do-mouse-mdown:expr))
(~optional (~seq #:on-mouse-release-left   (   lup-x:expr    lup-y:expr)    do-mouse-lup:expr))
(~optional (~seq #:on-mouse-release-right  (   rup-x:expr    rup-y:expr)    do-mouse-rup:expr))
(~optional (~seq #:on-mouse-release-middle (   mup-x:expr    mup-y:expr)    do-mouse-mup:expr))
(~optional (~seq #:on-mouse-wheel-down do-mouse-wheeld:expr))
(~optional (~seq #:on-mouse-wheel-up   do-mouse-wheelu:expr))
            form:expr)
      ...)
   #'(#%module-begin

      (require racket/class
               racket/gui/base)

      (provide the-frame the-canvas% the-canvas the-application
               the-application-thread)

      form ...

      (define the-frame (new frame% [label (~? title "graphics-engine")]))

      (define the-canvas%
        (class (~? canvas-class% opengl-canvas%)
          (super-new)
          (define/override (on-char event)
            (match* ((send event get-key-code)
                     (send event get-key-release-code))
              (~? [('wheel-down 'press) do-mouse-wheeld])
              (~? [('wheel-up   'press) do-mouse-wheelu])
              [( press-k 'press   ) do-key-press  ] ...
              [('release release-k) do-key-release] ...
              [(key0     key1     ) do-key        ] ...
              [(_        _        ) (super on-char event)]))
          (define/override (on-event event)
            (match* ((send event get-event-type)
                     (send event get-x)
                     (send event get-y))
              (~? [(     'motion motion-x motion-y) do-mouse-motion])
              (~? [(      'enter  enter-x  enter-y) do-mouse-enter ])
              (~? [(      'leave  leave-x  leave-y) do-mouse-leave ])
              (~? [(  'left-down  ldown-x  ldown-y) do-mouse-ldown ])
              (~? [( 'right-down  rdown-x  rdown-y) do-mouse-rdown ])
              (~? [('middle-down  mdown-x  mdown-y) do-mouse-mdown ])
              (~? [(    'left-up    lup-x    lup-y) do-mouse-lup   ])
              (~? [(   'right-up    rup-x    rup-y) do-mouse-rup   ])
              (~? [(  'middle-up    mup-x    mup-y) do-mouse-mup   ])
              [(mouse0 mouse-x mouse-y) do-mouse] ...
              [(_      _       _      ) (super on-event event)]))))

      (define the-canvas (new the-canvas%
                              [     parent the-frame        ]
                              [  min-width (~? width  800  )]
                              [ min-height (~? height 600  )]
                              [   verbose? (~? info?  #f   )]
                              [clear-color (~? color  black)]))

      (define the-application
        (application
         the-frame the-canvas
         (~? do-start void)
         (~? (~@ (λ draw-rest do-draw ...) null)
             (~? (~@ (λ (draw-var ...) do-draw ...) (list draw-arg ...))
                 (~@ values null)))))

      (define the-application-thread (run the-application)))])
