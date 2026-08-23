;;; markdown.el --- Markdown configuration -*- lexical-binding: t; byte-compile-docstring-max-column: 100; -*-

;;; Commentary:

;; Configure context-sensitive Markdown editing commands and bindings.

;;; Code:

(require 'hydra)
(require 'leaf)
(require 'markdown-ts-mode)

(leaf markdown-ts-mode
  :mode ("\\.md\\'" "\\ISSUE_EDITMSG\\'")
  :preface
  (defun dotfiles/markdown-demote-or-indent ()
    (interactive)
    (cond
     ((markdown-ts-at-table-p nil t) (markdown-ts-table-next-cell))
     ((markdown-ts-at-code-block-p) (indent-for-tab-command))
     ((or (markdown-ts--heading-at-point)
          (markdown-ts--list-item-at-point))
      (markdown-ts-demote))
     (t (indent-for-tab-command))))
  (defun dotfiles/markdown-promote-or-cycle ()
    (interactive)
    (cond
     ((markdown-ts-at-table-p nil t) (markdown-ts-table-previous-cell))
     ((markdown-ts-at-code-block-p) (indent-for-tab-command))
     ((or (markdown-ts--heading-at-point)
          (markdown-ts--list-item-at-point))
      (markdown-ts-promote))
     (t (outline-cycle-buffer))))
  (defhydra dotfiles/markdown-menu (:color blue :hint nil)
    "
Markdown: _a_lign table  _e_mphasize  _h_ide markup  _i_mages
          _r_enumber     _s_tructure  _x_ checkbox  _q_ quit
"
    ("a" markdown-ts-table-align-table)
    ("e" markdown-ts-emphasize)
    ("h" markdown-ts-toggle-hide-markup)
    ("i" markdown-ts-toggle-inline-images)
    ("r" markdown-ts-renumber-list)
    ("s" markdown-ts-insert-structure)
    ("x" markdown-ts-toggle-checkbox)
    ("q" nil))
  :bind (:markdown-ts-mode-map
         ("<backtab>" . dotfiles/markdown-promote-or-cycle)
         ("<S-tab>"   . dotfiles/markdown-promote-or-cycle)
         ("<tab>"     . dotfiles/markdown-demote-or-indent)
         ("C-c m"     . dotfiles/markdown-menu/body)
         ("M-n"       . markdown-ts-move-subtree-down)
         ("M-p"       . markdown-ts-move-subtree-up)
         ("TAB"       . dotfiles/markdown-demote-or-indent)))

(provide 'dotfiles-markdown)

;;; markdown.el ends here
