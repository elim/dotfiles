;;; early-init.el --- undoc
;;; Commentary:

;;; Code:

(set-variable 'ns-use-native-fullscreen nil)
(set-variable 'x-super-keysym 'meta)
(set-variable 'gc-cons-threshold (* 128 1024 1024))
(set-variable 'load-prefer-newer t)
(set-variable 'custom-file (locate-user-emacs-file ".custom.el"))
;; Keep native-comp warnings quiet during startup and async compilation.
(set-variable 'native-comp-async-report-warnings-errors 'silent)

(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)

(push '(fullscreen . maximized) default-frame-alist)

(provide 'early-init)
;;; early-init.el ends here
