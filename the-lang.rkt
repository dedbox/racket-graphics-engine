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

(provide current-canvas% the-canvas% μ mu
         (all-from-out graphics-engine)
         (except-out (all-from-out racket/base) #%module-begin)
         (rename-out [module-begin #%module-begin]))

(define-the-thing the-canvas% current-canvas%)

(define-syntax (μ stx) (raise-syntax-error #f "invalid syntax" stx))
(define-syntax (mu stx) (raise-syntax-error #f "invalid syntax" stx))

(begin-for-syntax
  (define-syntax-class (mu-abs len)
    #:description "match abstraction"
    #:attributes ([arg 1] arg0 [args0 1] [body 1] [_ 1])
    (pattern ((~or (~literal μ) (~literal mu))
              (~and (~or () (arg0 args0 ...)) (arg ...)) body ...)
             #:attr (_ 1) (let ([num-args (length (attribute arg))])
                            (for/list ([_ (in-range (- len num-args))]) #'_)))))

(define-simple-macro
  (module-begin (~alt
                 (~optional (~seq #:min-width   ~! width:expr))
                 (~optional (~seq #:min-height  ~! height:expr))
                 (~optional (~seq #:clear-color ~! color:expr))
                 (~optional (~seq #:title    ~! title:expr))
                 (~optional (~seq #:legacy?  ~! compat?:expr))
                 (~optional (~seq #:verbose? ~! info?:expr))
                 (~optional (~seq #:on-size  ~! (~var size (mu-abs 2))))
                 (~optional (~seq #:canvas   ~! do-canvas%:expr))
                 (~optional (~seq #:on-start ~!   do-start:expr))
                 (~optional (~seq #:on-draw  ~!    do-draw:expr))
                 (~optional (~seq #:on-idle  ~!    do-idle:expr))
                 (~seq #:on-key         ~! (~var key       (mu-abs 7)))
                 (~seq #:on-key-press   ~! (~var k-press   (mu-abs 6)))
                 (~seq #:on-key-release ~! (~var k-release (mu-abs 6)))
                 (~seq #:on-mouse       ~! (~var mouse     (mu-abs 6)))
                 (~optional (~seq #:on-mouse-wheel     ~! (~var m-wheel     (mu-abs 7))))
                 (~optional (~seq #:on-mouse-wheel-up  ~! (~var m-wheel-up  (mu-abs 7))))
                 (~optional (~seq #:on-mouse-motion    ~! (~var m-motion    (mu-abs 5))))
                 (~optional (~seq #:on-mouse-enter     ~! (~var m-enter     (mu-abs 5))))
                 (~optional (~seq #:on-mouse-leave     ~! (~var m-leave     (mu-abs 5))))
                 (~optional (~seq #:on-mouse-left      ~! (~var m-left      (mu-abs 5))))
                 (~optional (~seq #:on-mouse-right     ~! (~var m-right     (mu-abs 5))))
                 (~optional (~seq #:on-mouse-middle    ~! (~var m-middle    (mu-abs 5))))
                 (~optional (~seq #:on-mouse-left-up   ~! (~var m-left-up   (mu-abs 5))))
                 (~optional (~seq #:on-mouse-right-up  ~! (~var m-right-up  (mu-abs 5))))
                 (~optional (~seq #:on-mouse-middle-up ~! (~var m-middle-up (mu-abs 5))))
                 form:expr) ...)
  (#%module-begin

   (require racket/class
            racket/gui/base)

   form ...

   (current-frame (new frame% [label (~? title "graphics-engine")]))

   (current-canvas%
    (class (~? (do-canvas%) opengl-canvas%)
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
                        [parent      the-frame      ]
                        [min-width   (~? width  800)]
                        [min-height  (~? height 600)]
                        [legacy?     (~? compat? #f)]
                        [verbose?    (~? info?   #f)]
                        [clear-color (~? color black)]))

   (current-application (application (current-frame)
                                     (current-canvas)
                                     (~? do-start #f)
                                     (~? do-draw #f)
                                     (~? do-idle #f)))

   (current-process (run (current-application)))))
