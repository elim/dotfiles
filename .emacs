;-*- emacs-lisp -*-
; $Id$

(setq my-lisp-path (expand-file-name "~/lib/site-lisp/"))

(setq load-path
      (append
       (list (expand-file-name my-lisp-path))
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

