;;; early-init.el --- undoc -*- lexical-binding: t; -*-
;;; Commentary:

;;; Code:

(defvar x-super-keysym)

(setopt gc-cons-threshold (* 128 1024 1024)
        ns-use-native-fullscreen nil)

(setq x-super-keysym 'meta
      load-prefer-newer t
      custom-file (locate-user-emacs-file ".custom.el"))

(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)

(push '(fullscreen . maximized) default-frame-alist)

(provide 'early-init)
;;; early-init.el ends here
