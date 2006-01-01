;-*- emacs-lisp -*-
; $Id$

(setq load-path
      (append
       (list (expand-file-name "~/lib/site-lisp/"))
       (if (file-accessible-directory-p
	    "/usr/local/share/emacs/site-lisp/")
	   (list (expand-file-name "/usr/local/share/emacs/site-lisp/")))
       load-path))

(setq exec-path
      (append
       (when (file-accessible-directory-p "/sw/bin")
	 (list (expand-file-name "/sw/bin")))
       (when (file-accessible-directory-p "/sw/sbin")
	 (list (expand-file-name "/sw/sbin")))
       exec-path))

(load "init-emacs.el")

