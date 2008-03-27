;; -*- mode: emacs-lisp; coding: utf-8-unix -*-
;; $Id$

(when (require 'ruby-mode nil t)
  (setq ruby-indent-level 2
	ruby-indent-tabs-mode nil
	ruby-indnt-paren-style nil)

  (mapc '(lambda (lst)
	   (add-to-list 'auto-mode-alist lst))
	(list '("\\.rb$" . ruby-mode)
	      '("Rakefile" . ruby-mode)))

  (when (require 'ruby-electric nil t)
    (setq ruby-electric-expand-delimiters-list '(?\{))
    (add-hook 'ruby-mode-hook
	      '(lambda ()
		 (ruby-electric-mode 1))))

  (when (require 'inf-ruby nil t)
    (setq interpreter-mode-alist
	  (cons '("ruby" . ruby-mode) interpreter-mode-alist))
    (let
	((ruby (locate-executable "ruby"))
	 (irb (locate-library "irb" nil exec-path))
	 (args (list "--inf-ruby-mode" "-Ku")))

      (and irb
	   (setq ruby-program-name
		 (mapconcat #'identity
			    `(,ruby ,irb ,@args) " "))

	   (add-hook 'ruby-mode-hook
		     '(lambda ()
			(inf-ruby-keys)))

	   (add-hook 'inferior-ruby-mode-hook
		     '(lambda ()
			(mapc '(lambda (lst)
				 (apply #'define-key (current-local-map) lst))
			      (list
			       '("\C-p"  comint-previous-input)
			       '("\C-n"  comint-next-input)))))))))