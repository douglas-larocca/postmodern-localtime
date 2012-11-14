;;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-
(in-package #:cl-user)
(defpackage #:postmodern-localtime-asd (:use #:asdf #:cl))
(in-package #:postmodern-localtime-asd)

(defsystem postmodern-localtime
    :name "postmodern-localtime"
    :version "0.0.1"
    :maintainer "Vassilis Radis"
    :author "Vassilis Radis"
    :licence "You don't even have to buy me a beer"
	:serial t
    :description "postmodern-localtime"
    :depends-on (:postmodern :cl-postgres :local-time)
    :components((:file "postmodern-localtime")))