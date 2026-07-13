;;; elim-clipboard-monitor.el --- Record system clipboard history -*- lexical-binding: t; -*-

;; This file is not part of GNU Emacs.

;;; Code:

(defgroup elim:clipboard-monitor nil
  "Record system clipboard history in the kill ring."
  :group 'killing)

(defcustom elim:clipboard-monitor-interval 0.5
  "Seconds between checks of the system clipboard."
  :type 'number
  :group 'elim:clipboard-monitor)

(defvar elim:clipboard-monitor-timer nil)
(defvar elim:clipboard-monitor-last-text nil)
(defvar elim:clipboard-monitor-last-error nil)

(defun elim:clipboard-monitor-read ()
  "Return plain text from the system clipboard."
  (let ((types (if (memq window-system '(x pgtk))
                   '(UTF8_STRING COMPOUND_TEXT STRING text/plain\;charset=utf-8)
                 '(STRING)))
        text
        last-error)
    (while (and types (not text))
      (condition-case error
          (setq text (gui-get-selection 'CLIPBOARD (pop types)))
        (error
         (setq last-error error))))
    (when (and (not text) last-error)
      (signal (car last-error) (cdr last-error)))
    (and (stringp text) (substring-no-properties text))))

(defun elim:clipboard-monitor-check ()
  "Add changed system clipboard text to `kill-ring'."
  (condition-case error
      (let ((text (elim:clipboard-monitor-read)))
        (setq elim:clipboard-monitor-last-error nil)
        (unless (equal text elim:clipboard-monitor-last-text)
          (setq elim:clipboard-monitor-last-text text)
          (when (and text (not (string-empty-p text)))
            ;; Recording history must not replace the system clipboard.
            (let ((interprogram-cut-function nil)
                  (interprogram-paste-function nil))
              (kill-new text)))))
    (error
     (unless (equal error elim:clipboard-monitor-last-error)
       (display-warning 'elim:clipboard-monitor
                        (error-message-string error)))
     (setq elim:clipboard-monitor-last-error error))))

(define-minor-mode elim:clipboard-monitor-mode
  "Record text copied by other applications in `kill-ring'."
  :global t
  :lighter ""
  (when (timerp elim:clipboard-monitor-timer)
    (cancel-timer elim:clipboard-monitor-timer))
  (setq elim:clipboard-monitor-timer
        (when elim:clipboard-monitor-mode
          (run-with-timer 0 elim:clipboard-monitor-interval
                          #'elim:clipboard-monitor-check))))

(defun elim:clipboard-monitor-status ()
  "Report clipboard monitor health without exposing clipboard contents."
  (interactive)
  (message "Clipboard monitor: %s; last error: %s"
           (if (and (timerp elim:clipboard-monitor-timer)
                    (memq elim:clipboard-monitor-timer timer-list))
               "running"
             "stopped")
           (if elim:clipboard-monitor-last-error
               (error-message-string elim:clipboard-monitor-last-error)
             "none")))

(provide 'elim-clipboard-monitor)
;;; elim-clipboard-monitor.el ends here
