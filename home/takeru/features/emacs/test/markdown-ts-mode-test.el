;;; markdown-ts-mode-test.el --- Tests for Markdown configuration -*- lexical-binding: t; -*-

;;; Commentary:

;; Test the context-sensitive bindings configured for `markdown-ts-mode'.

;;; Code:

(require 'ert)
(require 'leaf)

(load (expand-file-name "../init.el"
                        (file-name-directory (or load-file-name
                                                 buffer-file-name)))
      nil nil t)

(declare-function elim:markdown-ts-demote-or-indent "../init")
(declare-function elim:markdown-ts-menu/body "../init")
(declare-function elim:markdown-ts-promote-or-cycle "../init")
(declare-function markdown-ts-mode "markdown-ts-mode")
(declare-function markdown-ts-move-subtree-down "markdown-ts-mode")
(declare-function markdown-ts-move-subtree-up "markdown-ts-mode")

(defmacro elim:test-with-markdown (text &rest body)
  "Create a Markdown buffer containing TEXT and evaluate BODY."
  (declare (indent 1) (debug t))
  `(with-temp-buffer
     (insert ,text)
     (markdown-ts-mode)
     (goto-char (point-min))
     ,@body))

(ert-deftest elim:markdown-ts-demote-and-promote-heading ()
  (elim:test-with-markdown "# Heading\n"
    (elim:markdown-ts-demote-or-indent)
    (should (equal (buffer-string) "## Heading\n"))
    (elim:markdown-ts-promote-or-cycle)
    (should (equal (buffer-string) "# Heading\n"))))

(ert-deftest elim:markdown-ts-demote-and-promote-list-item ()
  (elim:test-with-markdown "- first\n- second\n"
    (forward-line 1)
    (elim:markdown-ts-demote-or-indent)
    (should (equal (buffer-string) "- first\n  - second\n"))
    (elim:markdown-ts-promote-or-cycle)
    (should (equal (buffer-string) "- first\n- second\n"))))

(ert-deftest elim:markdown-ts-move-list-item-without-arrow-keys ()
  (elim:test-with-markdown "- first\n- second\n"
    (markdown-ts-move-subtree-down)
    (should (equal (buffer-string) "- second\n- first\n"))
    (should (eq (key-binding (kbd "M-n"))
                #'markdown-ts-move-subtree-down))
    (should (eq (key-binding (kbd "M-p"))
                #'markdown-ts-move-subtree-up))))

(ert-deftest elim:markdown-ts-menu-is-available ()
  (elim:test-with-markdown "# Heading\n"
    (should (fboundp 'elim:markdown-ts-menu/body))
    (should (eq (key-binding (kbd "C-c m"))
                #'elim:markdown-ts-menu/body))))

(ert-deftest elim:markdown-ts-tab-keeps-code-indentation ()
  (let (called)
    (cl-letf (((symbol-function 'markdown-ts-at-table-p)
               (lambda (&rest _) nil))
              ((symbol-function 'markdown-ts-at-code-block-p) (lambda () t))
              ((symbol-function 'indent-for-tab-command)
               (lambda () (setq called 'indent))))
      (elim:markdown-ts-demote-or-indent)
      (should (eq called 'indent))
      (setq called nil)
      (elim:markdown-ts-promote-or-cycle)
      (should (eq called 'indent)))))

(ert-deftest elim:markdown-ts-tab-keeps-table-navigation ()
  (let (called)
    (cl-letf (((symbol-function 'markdown-ts-at-table-p)
               (lambda (&rest _) t))
              ((symbol-function 'markdown-ts-table-next-cell)
               (lambda () (setq called 'next)))
              ((symbol-function 'markdown-ts-table-previous-cell)
               (lambda () (setq called 'previous))))
      (elim:markdown-ts-demote-or-indent)
      (should (eq called 'next))
      (elim:markdown-ts-promote-or-cycle)
      (should (eq called 'previous)))))

(provide 'markdown-ts-mode-test)

;;; markdown-ts-mode-test.el ends here
