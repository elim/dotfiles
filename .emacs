;-*- emacs-lisp -*-

;; ~/.elisp を load-path の先頭に加える
(setq load-path (append (list (expand-file-name "~/lib/site-lisp/")) load-path))
;(add-to-list 'load-path "~/lib/site-lisp/init")

(load "init-emacs.el")
