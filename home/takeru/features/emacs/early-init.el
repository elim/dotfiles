;;; early-init.el --- undoc
;;; Commentary:

;;; Code:

(setq ns-use-native-fullscreen nil
      x-super-keysym 'meta
      gc-cons-threshold (* 128 1024 1024)
      load-prefer-newer t
      custom-file (locate-user-emacs-file ".custom.el"))
;; Keep native-comp warnings quiet during startup and async compilation.
(setq native-comp-async-report-warnings-errors 'silent)

(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)

(push '(fullscreen . maximized) default-frame-alist)

(provide 'early-init)
;;; early-init.el ends here
