;-*- emacs-lisp -*-
; $Id$

;; ~/lib/site-lisp を load-path の先頭に加える
(setq load-path
      (append (list (expand-file-name "~/lib/site-lisp/")) load-path))

(load "init-emacs.el")

