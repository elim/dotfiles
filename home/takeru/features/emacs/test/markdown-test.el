;;; markdown-test.el --- Tests for Markdown configuration -*- lexical-binding: t; -*-

;;; Commentary:

;; Test the context-sensitive bindings configured for `markdown-ts-mode'.

;;; Code:

(require 'ert)

(load (expand-file-name "../config/markdown.el"
                        (file-name-directory (or load-file-name
                                                 buffer-file-name)))
      nil nil t)

(declare-function dotfiles/markdown-demote-or-indent "../config/markdown")
(declare-function dotfiles/markdown-menu/body "../config/markdown")
(declare-function dotfiles/markdown-promote-or-cycle "../config/markdown")
(declare-function markdown-ts-mode "markdown-ts-mode")
(declare-function markdown-ts-move-subtree-down "markdown-ts-mode")
(declare-function markdown-ts-move-subtree-up "markdown-ts-mode")

(defmacro dotfiles-test/with-markdown (text &rest body)
  "Create a Markdown buffer containing TEXT and evaluate BODY."
  (declare (indent 1) (debug t))
  `(with-temp-buffer
     (insert ,text)
     (markdown-ts-mode)
     (goto-char (point-min))
     ,@body))

(ert-deftest dotfiles-test/markdown-demote-and-promote-heading ()
  (dotfiles-test/with-markdown "# Heading\n"
    (dotfiles/markdown-demote-or-indent)
    (should (equal (buffer-string) "## Heading\n"))
    (dotfiles/markdown-promote-or-cycle)
    (should (equal (buffer-string) "# Heading\n"))))

(ert-deftest dotfiles-test/markdown-demote-and-promote-list-item ()
  (dotfiles-test/with-markdown "- first\n- second\n"
    (forward-line 1)
    (dotfiles/markdown-demote-or-indent)
    (should (equal (buffer-string) "- first\n  - second\n"))
    (dotfiles/markdown-promote-or-cycle)
    (should (equal (buffer-string) "- first\n- second\n"))))

(ert-deftest dotfiles-test/markdown-move-list-item-without-arrow-keys ()
  (dotfiles-test/with-markdown "- first\n- second\n"
    (markdown-ts-move-subtree-down)
    (should (equal (buffer-string) "- second\n- first\n"))
    (should (eq (key-binding (kbd "M-n"))
                #'markdown-ts-move-subtree-down))
    (should (eq (key-binding (kbd "M-p"))
                #'markdown-ts-move-subtree-up))))

(ert-deftest dotfiles-test/markdown-menu-is-available ()
  (dotfiles-test/with-markdown "# Heading\n"
    (should (fboundp 'dotfiles/markdown-menu/body))
    (should (eq (key-binding (kbd "C-c m"))
                #'dotfiles/markdown-menu/body))))

(ert-deftest dotfiles-test/markdown-tab-keeps-code-indentation ()
  (let (called)
    (cl-letf (((symbol-function 'markdown-ts-at-table-p)
               (lambda (&rest _) nil))
              ((symbol-function 'markdown-ts-at-code-block-p) (lambda () t))
              ((symbol-function 'indent-for-tab-command)
               (lambda () (setq called 'indent))))
      (dotfiles/markdown-demote-or-indent)
      (should (eq called 'indent))
      (setq called nil)
      (dotfiles/markdown-promote-or-cycle)
      (should (eq called 'indent)))))

(ert-deftest dotfiles-test/markdown-tab-keeps-table-navigation ()
  (let (called)
    (cl-letf (((symbol-function 'markdown-ts-at-table-p)
               (lambda (&rest _) t))
              ((symbol-function 'markdown-ts-table-next-cell)
               (lambda () (setq called 'next)))
              ((symbol-function 'markdown-ts-table-previous-cell)
               (lambda () (setq called 'previous))))
      (dotfiles/markdown-demote-or-indent)
      (should (eq called 'next))
      (dotfiles/markdown-promote-or-cycle)
      (should (eq called 'previous)))))

(provide 'dotfiles-markdown-test)

;;; markdown-test.el ends here
