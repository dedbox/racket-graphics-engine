#lang racket/base

(require graphics-engine
         graphics-engine/private
         racket/base
         racket/match
         syntax/parse/define
         (for-syntax racket/base
                     racket/function
                     syntax/strip-context
                     syntax/transformer))

(provide current-canvas%
         current-application
         current-application-thread
         the-canvas%
         the-application
         the-application-thread
         (all-from-out graphics-engine)
         (except-out (all-from-out racket/base) #%module-begin)
         (rename-out [module-begin #%module-begin]))

(define-the-things
  [the-canvas%            current-canvas%           ]
  [the-application        current-application       ]
  [the-application-thread current-application-thread])

(begin-for-syntax
  (define-syntax-class (lam len)
    #:description #f
    #:attributes (name [arg 1] arg0 [args0 1] [body 1] [_ 1])
    #:literals (λ lambda)
    (pattern (~and ((~and (~or λ lambda) name) (arg ...) body ...)
                   (~bind [(_ 1) (build-list (- len (length (syntax->list #'(arg ...))))
                                             (λ _ #'_))]))
             #:with (~or () (arg0 args0 ...)) #'(arg ...))))

(define-syntax-parser module-begin
  #:literals (λ lambda)
  [(_ (~alt
       (~optional (~seq #:title       ~! title:expr))
       (~optional (~seq #:min-width   ~! width:expr))
       (~optional (~seq #:min-height  ~! height:expr))
       (~optional (~seq #:clear-color ~! color:expr))
       (~optional (~seq #:verbose?    ~! info?:expr))
       (~optional (~seq #:canvas   ~! (~var canvas-class% (lam 0))))
       (~optional (~seq #:on-start ~! (~var start (lam 0))))
       (~optional (~seq #:on-size  ~! (~var size  (lam 2))))
       (~optional (~seq #:on-draw  ~!
                        ((~or λ lambda)
                         (~or draw-rest0:id
                              ([draw-var:id draw-arg:expr] ...)
                              ([draw-var:id draw-arg:expr] ... . draw-rest:id))
                         do-draw:expr ...)))
       (~seq #:on-key         ~! (~var key       (lam 7)))
       (~seq #:on-key-press   ~! (~var k-press   (lam 6)))
       (~seq #:on-key-release ~! (~var k-release (lam 6)))
       (~seq #:on-mouse       ~! (~var mouse     (lam 6)))
       (~optional (~seq #:on-mouse-wheel     ~! (~var m-wheel      (lam 7))))
       (~optional (~seq #:on-mouse-wheel-up  ~! (~var m-wheel-up   (lam 7))))
       (~optional (~seq #:on-mouse-motion    ~! (~var m-motion     (lam 5))))
       (~optional (~seq #:on-mouse-enter     ~! (~var m-enter      (lam 5))))
       (~optional (~seq #:on-mouse-leave     ~! (~var m-leave      (lam 5))))
       (~optional (~seq #:on-mouse-left      ~! (~var m-left       (lam 5))))
       (~optional (~seq #:on-mouse-right     ~! (~var m-right      (lam 5))))
       (~optional (~seq #:on-mouse-middle    ~! (~var m-middle     (lam 5))))
       (~optional (~seq #:on-mouse-left-up   ~! (~var m-left-up    (lam 5))))
       (~optional (~seq #:on-mouse-right-up  ~! (~var m-right-up   (lam 5))))
       (~optional (~seq #:on-mouse-middle-up ~! (~var m-middle-up  (lam 5))))
       form:expr)
      ...)

   (syntax/loc this-syntax
     (#%module-begin

      (require racket/class
               racket/gui/base)

      form ...

      (current-frame (new frame% [label (~? title "graphics-engine")]))

      (current-canvas%
       (class (~? ((λ () canvas-class%.body ...)) opengl-canvas%)
         (super-new)

         (~? (define/override (on-size size.arg ...) size.body ...))

         (define/override (on-char event)
           (match* ((send event get-key-code)
                    (send event get-key-release-code)
                    (key-mods event)
                    (send event get-x)
                    (send event get-y)
                    (send event get-time-stamp)
                    (send event get-control+meta-is-altgr))
             (~? [('wheel-down 'press  m-wheel.arg ...    m-wheel._ ...)    m-wheel.body ...])
             (~? [('wheel-up 'press m-wheel-up.arg ... m-wheel-up._ ...) m-wheel-up.body ...])
             [(k-press.arg0 'press k-press.args0 ... k-press._ ...) k-press.body ...] ...
             [('release k-release.arg ... k-release._ ...) k-release.body ...] ...
             [(key.arg ... key._ ...) key.body ...] ...
             [(_ _ _ _ _ _ _) (super on-char event)]))

         (define/override (on-event event)
           (match* ((send event get-event-type)
                    (send event get-x)
                    (send event get-y)
                    (mouse-buttons event)
                    (key-mods event)
                    (send event get-time-stamp))
             (~? [(     'motion    m-motion.arg ...    m-motion._ ...)    m-motion.body ...])
             (~? [(      'enter     m-enter.arg ...     m-enter._ ...)     m-enter.body ...])
             (~? [(      'leave     m-leave.arg ...     m-leave._ ...)     m-leave.body ...])
             (~? [(  'left-down      m-left.arg ...      m-left._ ...)      m-left.body ...])
             (~? [( 'right-down     m-right.arg ...     m-right._ ...)     m-right.body ...])
             (~? [('middle-down    m-middle.arg ...    m-middle._ ...)    m-middle.body ...])
             (~? [(    'left-up   m-left-up.arg ...   m-left-up._ ...)   m-left-up.body ...])
             (~? [(   'right-up  m-right-up.arg ...  m-right-up._ ...)  m-right-up.body ...])
             (~? [(  'middle-up m-middle-up.arg ... m-middle-up._ ...) m-middle-up.body ...])
             [(mouse.arg ... mouse._ ...) mouse.body ...] ...
             [(_ _ _ _ _ _) (super on-event event)]))))

      (current-canvas (new (current-canvas%)
                           [parent      the-frame       ]
                           [min-width   (~? width  800) ]
                           [min-height  (~? height 600) ]
                           [verbose?    (~? info?  #f ) ]
                           [clear-color (~? color black)]))

      (current-application
       (application
        (current-frame)
        (current-canvas)
        (~? (λ () start.body ...) void)
        (~? (~@ (λ (~? draw-rest0 (~? (draw-var ... . draw-rest) (draw-var ...)))
                  do-draw ...)
                (~? (list draw-arg ...) null))
            (~@ values null))))

      (current-application-thread (run (current-application)))))])