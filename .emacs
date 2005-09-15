;-*- emacs-lisp -*-
; $Id$

(setq load-path
      (append
       (list (expand-file-name "~/lib/site-lisp/"))
       (if (file-accessible-directory-p
	    "/usr/local/share/emacs/site-lisp/")
	   (list (expand-file-name "/usr/local/share/emacs/site-lisp/")))
       load-path))

(load "init-emacs.el")

