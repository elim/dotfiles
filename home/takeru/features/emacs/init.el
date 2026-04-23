;;; init.el --- A setting of my own Emacs. -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(set-variable 'debug-on-error t)
(set-variable 'init-file-debug t)

;; NOTE: I'm restructuring this file to match the new package groups
;; in my Nix setup. These headings are the first step. The plan is to
;; move everything under them, assuming I don't get a better idea tomorrow!

;;; Core framework packages

(eval-and-compile
  (require 'leaf)
  (leaf leaf-keywords
    :require t hydra blackout
    :config  (leaf-keywords-init)))

;;; Navigation / Completion

(leaf *completion
  :url https://blog.tomoya.dev/posts/a-new-wave-has-arrived-at-emacs
  :url https://emacs-jp.slack.com/archives/C1B5WTJLQ/p1623851956426000
  :url https://github.com/uwabami/emacs
  :config
  (leaf affe
    :after orderless
    :custom
    ((affe-highlight-function . 'orderless-highlight-matches)
     (affe-regexp-function  . 'orderless-pattern-compiler)))
  (leaf consult
    :defun consult-line
    :preface
    ;; C-uを付けるとカーソル位置の文字列を使うmy-consult-lineコマンドを定義する
    (defun tomoya:consult-line (&optional at-point)
      "Consult-line uses things-at-point if set C-u prefix."
      (interactive "P")
      (if at-point
          (consult-line (thing-at-point 'symbol))
        (consult-line)))
    :bind (([remap switch-to-buffer]              . consult-buffer)              ; C-x b
           ([remap switch-to-buffer-other-window] . consult-buffer-other-window) ; C-x 4 b
           ([remap display-buffer-other-frame]    . consult-buffer-other-frame)  ; C-x 5 b
           ([remap repeat-complex-command]        . consult-complex-command)     ; C-x C-:
           ([remap pop-global-mark]               . consult-global-mark)         ; C-x C-SPC
           ([remap goto-line]                     . consult-goto-line)           ; M-g g
           ([remap yank-pop]                      . consult-yank-pop)            ; M-y

           ("C-;" . consult-buffer)
           ("C-x C-;" . consult-buffer)

           ("C-x C-o" . consult-file-externally) ; orig. delete-blank-lines
           ("C-x C-p" . consult-find)            ; orig. mark-page
           ("M-s M-s" . tomoya:consult-line)
           ("C-S-s"   . consult-imenu)           ; orig. imenu
           ))
  (leaf embark-consult
    :require t
    :after consult)
  (leaf marginalia
    :global-minor-mode t)
  (leaf orderless
    :custom (completion-styles . '(orderless)))
  (leaf savehist
    :global-minor-mode t)
  (leaf vertico
    :url https://github.com/uwabami/emacs
    :preface
    (defun uwabami:filename-upto-parent ()
      "Move to parent directory like \"cd ..\" in find-file."
      (interactive)
      (let ((sep (eval-when-compile (regexp-opt '("/" "\\")))))
        (save-excursion
          (left-char 1)
          (when (looking-at-p sep)
            (delete-char 1)))
        (save-match-data
          (when (search-backward-regexp sep nil t)
            (right-char 1)
            (filter-buffer-substring (point)
                                     (save-excursion (end-of-line) (point))
                                     #'delete)))))
    :bind (:vertico-map
           (("C-l" . uwabami:filename-upto-parent)
            ("C-r" . vertico-previous)
            ("C-s" . vertico-next)))
    :custom (vertico-count . 20)
    :global-minor-mode t)
  (leaf vertico-posframe
    :doc "Using posframe to show Vertico"
    :req "emacs-26.0" "posframe-1.1.4" "vertico-0.13.0"
    :tag "vertico" "matching" "convenience" "abbrev" "emacs>=26.0"
    :url "https://github.com/tumashu/vertico-posframe"
    :added "2022-03-02"
    :emacs>= 26.0
    :after posframe vertico
    :global-minor-mode t))

;;; Code completion and intelligence

(leaf eglot
  :doc "Built-in LSP client for modern development workflow"
  :custom ((eglot-autoshutdown . t)
           (eglot-extend-to-xref . t)))

;;; Version control

(leaf browse-at-remote
  :doc "Open github/gitlab/bitbucket/stash/gist/phab/sourcehut page from Emacs"
  :req "f-0.17.2" "s-1.9.0" "cl-lib-0.5"
  :tag "pagure" "sourcehut" "phabricator" "stash" "gist" "bitbucket" "gitlab" "github"
  :url "https://github.com/rmuslimov/browse-at-remote"
  :added "2022-12-22")

(leaf git-modes
  :doc "Major modes for editing Git configuration files"
  :req "emacs-25.1" "compat-29.1.3.4"
  :tag "git" "vc" "convenience" "emacs>=25.1"
  :url "https://github.com/magit/git-modes"
  :added "2023-04-14"
  :emacs>= 25.1
  :after compat)

(leaf vc
  :custom (vc-follow-symlinks . t))

;;; Programming languages

;; Lua development environment
(leaf lua-ts-mode
  :mode (("\\.lua\\'" . lua-ts-mode))
  :custom ((lua-ts-mode-indent-offset . 2)))

;; TypeScript and JavaScript development environment
(leaf *typescript-javascript
  :doc "Modern TypeScript/JavaScript development with tree-sitter and LSP"
  :config

  ;; Tree-sitter based modes
  (leaf typescript-ts-mode
    :mode (("\\.ts\\'" . typescript-ts-mode)
           ("\\.tsx\\'" . tsx-ts-mode)
           ("\\.js\\'" . js-ts-mode)
           ("\\.jsx\\'" . jsx-ts-mode))
    :custom ((typescript-ts-mode-indent-offset . 2)
             (js-ts-mode-indent-offset . 2))
    :hook ((typescript-ts-mode-hook tsx-ts-mode-hook js-ts-mode-hook) . eglot-ensure))

  ;; Node.js project integration
  (leaf add-node-modules-path
    :doc "npm bin is removed in npm v9"
    :url "https://github.com/codesuki/add-node-modules-path/issues/23"
    :custom (add-node-modules-path-command . '("echo \"$(npm root)/.bin\""))
    :hook ((typescript-ts-mode-hook js-ts-mode-hook) . add-node-modules-path)))

;;; Ruby support

;;; Markup and documentation

;;; Platform / Frame / Appearance

(leaf frame
  :if window-system
  :preface
  (defun elim:frame-startup-state ()
    ;; Avoid macOS fullscreen spaces: maximizing keeps the notch clear
    ;; without opting into native fullscreen animations.
    (set-frame-parameter
     nil 'fullscreen
     (if (eq system-type 'darwin) 'maximized 'fullboth)))
  :config
  (add-to-list 'default-frame-alist '(font . "HackGen Console NF-14"))
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
  (add-to-list 'default-frame-alist '(ns-appearance . dark))
  :custom ((line-spacing . 4))
  :hook (window-setup-hook . elim:frame-startup-state))

(leaf *fonts
  :defun elim:set-text-height
  :preface
  (defun elim:set-text-height (height)
    "Set to the HEIGHT and the family to the default face and some faces."
    (let* ((asciifont "HackGen NF") ; ASCII fonts
           (jpfont "HackGen NF")    ; Japanese fonts
           (fontspec (font-spec :family asciifont :weight 'normal))
           (jp-fontspec (font-spec :family jpfont :weight 'normal)))
      (set-face-attribute 'default     nil :family asciifont :height height)
      (set-face-attribute 'fixed-pitch nil :family asciifont :height height)
      (set-fontset-font nil 'japanese-jisx0213.2004-1 jp-fontspec)
      (set-fontset-font nil 'japanese-jisx0213-2      jp-fontspec)
      (set-fontset-font nil 'katakana-jisx0201        jp-fontspec)
      (set-fontset-font nil '(#x0080  .  #x024F)         fontspec)
      (set-fontset-font nil '(#x0370  .  #x03FF)         fontspec)
      (set-fontset-font nil '(#x1f809 . #x1f80a)         fontspec)
      (set-fontset-font nil 'unicode                     fontspec)))
  (defun elim:change-interactive-text-height ()
    (interactive)
    (let
        ((height (face-attribute 'default :height))
         (step 1) (char nil))
      (catch 'end:flag
        (while t
          (message "change text height. p:up n:down height:%s" height)
          (setq char (read-char))
          (cond
           ((= char ?p)
            (setq height (+ height step)))
           ((= char ?n)
            (setq height (- height step)))
           ((and (/= char ?p) (/= char ?n))
            (message "quit text height:%s" height)
            (throw 'end:flag t)))
          (elim:set-text-height height)))))
  :config
  (cond
   ((eq window-system 'ns)
    (set-variable 'ns-antialias-text t)
    (elim:set-text-height 180))
   ((or (eq window-system 'x)
        (eq window-system 'pgtk))
    (elim:set-text-height 129))))

(leaf ns
  :if (featurep 'ns)
  :custom
  ((ns-antialias-text        . t)
   (ns-pop-up-frames         . nil)
   (ns-use-native-fullscreen . nil)

   (ns-alternate-modifier       . 'meta)
   (ns-command-modifier         . 'meta)
   (ns-right-alternate-modifier . 'hyper)
   (ns-right-command-modifier   . 'super)))

(leaf doom-modeline
  :leaf-defer nil
  :defun doom-modeline-mode
  :custom
  ((doom-modeline-buffer-file-name-style . 'truncate-with-project)
   (doom-modeline-major-mode-icon . nil)
   (doom-modeline-minor-modes . nil)
   (inhibit-compacting-font-caches . t))
  :custom-face
  ((mode-line  . '((t (:height 160))))
   (mode-line-inactive . '((t (:height 160)))))
  :config (doom-modeline-mode))

(leaf hl-line
  :global-minor-mode global-hl-line-mode)

(leaf menu-bar
  :if (eq system-type 'darwin)
  :global-minor-mode t)

(leaf nyan-mode
  :leaf-defer nil
  :global-minor-mode t
  :custom ((nyan-animate-nyancat . t)
           (nyan-wavy-trail . t)))

(leaf scroll-bar
  :if (fboundp 'scroll-bar-mode)
  :config
  (set-scroll-bar-mode 'right)
  (scroll-bar-mode -1)
  :global-minor-mode column-number-mode)

(leaf *theme
  :config
  ;; (load-theme 'tango-dark t))
  (leaf doom-themes
    :custom ((doom-themes-enable-italic . t)
             (doom-themes-enable-bold . nil))
    :config
    ;; (load-theme 'doom-city-lights t)
    ;; (load-theme 'doom-dracula t)
    ;; (load-theme 'doom-nord t)
    (load-theme 'doom-one t)
    ;; (doom-themes-neotree-config)
    ;; (doom-themes-org-config)
    (set-face-attribute 'show-paren-match nil :weight 'normal)))

(leaf time
  :custom ((display-time-24hr-format . t))
  :config (display-time))

;;; Input method

;;; Editor enhancements

(leaf *editing-basics
  :custom ((delete-by-moving-to-trash . t)
           (kill-ring-max . 8192))
  :config
  (put 'list-timers 'disabled nil)
  (put 'scroll-left 'disabled nil))

;;; System integration

(defun elim:save-buffer-to-kill-ring ()
  "Save the current buffer's entire content to the kill ring."
  (kill-new (buffer-string)))

(leaf atomic-chrome
  :custom ((atomic-chrome-default-major-mode . 'markdown-mode)
           (atomic-chrome-url-major-mode-alist
            . '(("github\\.com" . gfm-mode)
                ("esa\\.io"     . gfm-mode)
                ("redmine"      . textile-mode))))
  :hook ((after-init-hook
          . atomic-chrome-start-server)
         (atomic-chrome-edit-done-hook
          . elim:save-buffer-to-kill-ring)))

(leaf direnv :global-minor-mode t)

(leaf server
  :require t
  :defun server-running-p
  :preface
  (defun elim:server-setup-edit-keys ()
    "Install convenient local bindings for server edit buffers."
    (when server-buffer-clients
      (let ((map (make-sparse-keymap)))
        (define-key map (kbd "C-c C-c") #'server-edit)
        (define-key map (kbd "C-c C-k") #'server-edit-abort)
        (push (cons t map) minor-mode-overriding-map-alist))))
  :custom (server-window . 'pop-to-buffer)
  :hook ((server-done-hook  . elim:save-buffer-to-kill-ring)
         (server-visit-hook . elim:server-setup-edit-keys))
  :config
  (unless (server-running-p) (server-start))
  (remove-hook
   'kill-buffer-query-functions
   'server-kill-buffer-query-function))

;;; Persistence and utilities

(leaf *utilities
  :config
  (leaf auth-source
    :custom `(auth-sources . '(,(locate-user-emacs-file ".authinfo.plist"))))
  (leaf browse-url
    :bind ("C-x m" . browse-url-at-point))
  (leaf bs
    :bind ("C-x C-b" . bs-show))
  (leaf clipmon
    :hook (after-init-hook . clipmon-mode-start)
    :config
    (when (fboundp 'gui-get-selection)
      (defun clipmon--get-selection ()
        "Get the clipboard contents. With a hack for Mozilla products, to set
         UTF8_STRING explicitly."
        (ignore-errors (gui-get-selection 'CLIPBOARD 'UTF8_STRING)))))
  (leaf dabbrev
    :custom ((dabbrev-abbrev-skip-leading-regexp . "\\$")))
  (leaf desktop
    :defvar desktop-globals-to-save
    :custom `((desktop-base-file-name      . ,(locate-user-emacs-file ".desktop.el"))
              (desktop-base-lock-name      . ,(locate-user-emacs-file ".desktop.lock"))
              (desktop-load-locked-desktop . 'check-pid)
              (desktop-restore-eager       . 0)
              (desktop-restore-frames      . nil)
              (desktop-save-mode           . +1))
    :config
    (add-to-list 'desktop-globals-to-save 'extended-command-history)
    (add-to-list 'desktop-globals-to-save 'kill-ring)
    (add-to-list 'desktop-globals-to-save 'log-edit-comment-ring)
    (add-to-list 'desktop-globals-to-save 'read-expression-history))
  (leaf find-func
    :config
    ;; C-x F => Find Function
    ;; C-x V => Find Variable
    ;; C-x K => Find Function on Key
    (find-function-setup-keys))
  (leaf dictionary
    :if (eq system-type 'darwin)
    :defun elim:dictionary-search
    :preface
    (defun elim:dictionary-search (word)
      (browse-url
       (concat "dict:///" (url-hexify-string word))))
    (defun elim:dictionary-word ()
      (interactive)
      (elim:dictionary-search
       (substring-no-properties (thing-at-point 'word))))
    (defun elim:dictionary-region (beg end)
      (interactive "r")
      (elim:dictionary-search
       (buffer-substring-no-properties beg end)))
    :bind (("C-x e" . elim:dictionary-word)
           ("C-x y" . elim:dictionary-region)))
  (leaf help-fns
    :bind (("H-b" . describe-binding)
           ("H-f" . describe-function)
           ("H-k" . describe-key)
           ("H-v" . describe-variable)))
  (leaf open-junk-file
    :bind (("C-x C-z" . open-junk-file))
    :custom ((open-junk-file-format . "~/.junk/%Y/%m/%d-%H%M%S.")
             (open-junk-file-find-file-function . 'find-file)))
  (leaf recentf
    :defvar recentf-auto-save-timer
    :custom `((recentf-auto-save-timer
               . ,(run-with-idle-timer 30 t #'recentf-save-list))
              (recentf-max-saved-items . 512)
              (recentf-save-file . ,(locate-user-emacs-file ".recentf.el")))
    :global-minor-mode t)
  (leaf sort
    :defun elim:sort-lines-nocase
    :config
    (defun elim:sort-lines-nocase ()
      "Ignore case when the sort the lines."
      (interactive)
      (defvar sort-fold-case)
      (let ((sort-fold-case t))
        (call-interactively 'sort-lines)))
    (defalias 'sort-lines-nocase #'elim:sort-lines-nocase)))

(leaf *environments
  :custom `((enable-recursive-minibuffers . t)
            (gc-cons-threshold . ,(* 128 1024 1024))
            (use-dialog-box . nil)
            (user-mail-address . "takeru.naito@gmail.com")
            (user-full-name . "Takeru Naito"))
  :config
  (defalias 'yes-or-no-p 'y-or-n-p)
  (leaf cus-edit
    :doc "Just prevent appending to this file (not load at startup)."
    :custom `((custom-file . ,(locate-user-emacs-file ".custom.el"))))
  (leaf simple
    :defun elim:editorconfig-mode-enabled-p
    :preface
    (defvar elim:auto-delete-trailing-whitespace-enable-p t)
    (defun elim:editorconfig-mode-enabled-p ()
      (assoc 'editorconfig-mode minor-mode-alist))
    (defun elim:auto-delete-trailing-whitespace ()
      (and elim:auto-delete-trailing-whitespace-enable-p
           (not (elim:editorconfig-mode-enabled-p))
           (delete-trailing-whitespace)))
    :bind (("<delete>" . delete-char)
           ("C-h"      . delete-char)
           ("C-m"      . newline-and-indent)
           ("C-x |"    . split-window-right)
           ("C-x -"    . split-window-below))
    :config
    (keyboard-translate ?\C-h ?\C-?)
    :global-minor-mode line-number-mode transient-mark-mode
    :hook (before-save-hook . elim:auto-delete-trailing-whitespace)))

(leaf *interfaces
  :custom ((frame-title-format . `(" %b " (buffer-file-name "( %f )")))
           (inhibit-startup-screen . t)
           (mouse-drag-copy-region . t)
           (read-buffer-completion-ignore-case . t)
           (read-file-name-completion-ignore-case .  t)
           (require-final-newline . t)
           (ring-bell-function . 'ignore)
           (scroll-conservatively . 1)
           (select-active-regions . nil)
           (show-trailing-whitespace . nil)
           (truncate-lines . nil)
           (visible-bell . t))
  :config
  (put 'dired-find-alternate-file 'disabled nil)
  (put 'narrow-to-region 'disabled nil)
  (put 'set-goal-column 'disabled nil)
  (set-default 'indent-tabs-mode nil)
  (set-default 'cursor-in-non-selected-windows nil)
  (leaf buffer-move
    :bind (("M-g h" . buf-move-left)
           ("M-g j" . buf-move-down)
           ("M-g k" . buf-move-up)
           ("M-g l" . buf-move-right)))
  (leaf company
    :bind (("C-M-i" . company-complete)
           (:company-active-map
            ("C-n" . company-select-next)
            ("C-p" . company-select-previous)
            ("C-s" . company-filter-candidates)
            ("C-i" . company-complete-selection)))
    :custom-face ((company-preview-common           . '((nil (:foreground "lightgrey" :underline t))))
                  (company-scrollbar-bg             . '((nil (:background "gray40"))))
                  (company-scrollbar-fg             . '((nil (:background "orange"))))
                  (company-tooltip                  . '((nil (:foreground "black" :background "lightgrey"))))
                  (company-tooltip-common           . '((nil (:foreground "black" :background "lightgrey"))))
                  (company-tooltip-common-selection . '((nil (:foreground "white" :background "steelblue"))))
                  (company-tooltip-selection        . '((nil (:foreground "black" :background "steelblue")))))
    :blackout company-mode
    :hook (after-init-hook . global-company-mode))
  (leaf company-quickhelp
    :global-minor-mode company-quickhelp-mode)
  (leaf executable
    :config
    (defun elim:executable-make-buffer-file-executable-if-script-p ()
      (unless (string-match tramp-file-name-regexp (buffer-file-name))
        (executable-make-buffer-file-executable-if-script-p)))
    :hook (after-save-hook . elim:executable-make-buffer-file-executable-if-script-p))
  (leaf font-core
    :config (global-font-lock-mode t))
  (leaf mouse
    :bind (("C-<down-mouse-1>" . nil)
           ("C-<drag-mouse-1>" . nil)
           ("S-<down-mouse-1>" . nil)
           ("S-<drag-mouse-1>" . nil)))
  (leaf popwin
    :defvar popwin:special-display-config
    :require t
    :custom ((popwin:popup-window-position . 'bottom)
             (popwin:popup-window-height . 20))
    :config
    (push '("*Google Translate*") popwin:special-display-config)
    :global-minor-mode t)
  (leaf rotate)
  (leaf select
    :custom ((select-enable-primary . nil)
             (select-enable-clipboard . t)
             (selection-coding-system . 'utf-8)))
  (leaf tab-bar
    :doc "frame-local tabs with named persistent window configurations"
    :tag "builtin"
    :added "2022-02-09"
    :bind-keymap ("C-z" . tab-bar-map)
    :bind `(("M-{" . tab-previous)
            ("M-}" . tab-next)
            (:tab-bar-map
             ("k" . tab-close)
             ("c" . tab-new)
             ("C-k" . tab-close)
             ("n" . tab-next)
             ("p" . tab-previous)
             ("C-SPC" . tab-recent)
             ,@(mapcar (lambda (i)
                         (cons (number-to-string i) 'tab-select))
                       (number-sequence 0 9))))
    :custom ((tab-bar-new-tab-choice . "*scratch*")
             (tab-bar-tab-hints . t))
    :custom-face
    ((tab-bar-tab .          '((nil (:foreground "#112" :background "#ccc"))))
     (tab-bar-tab-inactive . '((nil (:foreground "#ccc" :background "#112")))))
    :global-minor-mode t)
  (leaf uniquify
    :custom ((uniquify-buffer-name-style . 'post-forward-angle-brackets)
             (uniquify-ignore-buffers-re . "*[^*]+*")
             (uniquify-min-dir-content   . 1)))
  (leaf wgrep
    :custom ((wgrep-auto-save-buffer . t)))
  (leaf which-key
    :hook (after-init-hook . which-key-mode))
  (leaf windmove
    :custom ((windmove-wrap-around . t))
    :bind (("C-c C-b" . windmove-left)
           ("C-c C-n" . windmove-down)
           ("C-c C-p" . windmove-up)
           ("C-c C-f" . windmove-right))))

(leaf *minor-modes
  :config
  (leaf anzu
    :bind (([remap query-replace]        . anzu-query-replace)
           ([remap query-replace-regexp] . anzu-query-replace-regexp))
    :custom ((anzu-mode-lighter . "")
             (anzu-deactivate-region . t)
             (anzu-search-threshold . 1000))
    :global-minor-mode global-anzu-mode)
  (leaf autorevert
    :global-minor-mode global-auto-revert-mode)
  (leaf auto-save-visited-mode
    :bind ("C-x as" . auto-save-visited-mode)
    :leaf-defer nil
    :custom ((auto-save-visited-interval . 0.5))
    :global-minor-mode t)
  (leaf *dired
    :config
    (leaf dired
      :bind (:dired-mode-map
             ("SPC" . elim:dired-toggle-mark)
             ("r" . dired-toggle-read-only))
      :custom ((dired-recursive-copies . 'always)
               (dired-recursive-deletes . 'always))
      :defun dired-mark dired-unmark
      :preface
      ;; Mark with space (like the FD)
      (defun elim:dired-toggle-mark (arg)
        "Toggle the current (or next ARG) files."
        ;; Based on S.Namba Sat Aug 10 12:20:36 1996
        ;; Modernized for current Emacs
        (interactive "P")
        (let ((current-mark (char-after (line-beginning-position))))
          (if (eq current-mark ?\s)  ; If unmarked (space)
              (dired-mark arg)       ; Mark it
            (dired-unmark arg)))))   ; If marked, unmark it
    (leaf dired-x
      :custom ((dired-bind-jump . nil)
               (dired-guess-shell-alist-user
                . '(("\\.tar\\.gz\\'"  "tar tzvf")
                    ("\\.taz\\'" "tar ztvf")
                    ("\\.tar\\.bz2\\'" "tar tjvf")
                    ("\\.zip\\'" "unzip -l")
                    ("\\.\\(g\\|\\) z\\'" "zcat"))))))
  (leaf diff-mode
    :custom-face
    ((diff-added         . '((nil (:foreground "white" :background "dark green"))))
     (diff-removed       . '((nil (:foreground "white" :background "dark red"))))
     (diff-refine-change . '((nil (:foreground nil     :background nil :weight 'bold :inverse-video t))))))
  (leaf editorconfig
    :global-minor-mode editorconfig-mode
    :blackout editorconfig-mode)
  (leaf eldoc
    :custom ((eldoc-idle-delay . 0.2)
             (eldoc-minor-mode-string . ""))
    :hook ((emacs-lisp-mode
            lisp-interaction-mode
            ielm-mode-hook) . turn-on-eldoc-mode))
  (leaf *flycheck
    :config
    (leaf flycheck
      :hook (after-init-hook . global-flycheck-mode)
      :init (add-to-list 'exec-path (expand-file-name "bin" user-emacs-directory)))
    (leaf flycheck-posframe
      :after flycheck
      :hook (flycheck-mode-hook . flycheck-posframe-mode)))
  (leaf flyspell
    :custom ((ispell-dictionary . "american")
             (flyspell-use-meta-tab . nil)))
  (leaf google-translate
    :defun google-translate-translate
    :bind (("C-c t" . google-translate-enja-or-jaen))
    :custom (google-translate-backend-method . 'curl)
    :url http://emacs.rubikitch.com/google-translate/
    :config
    (defvar google-translate-english-chars "[:ascii:]"
      "If the target string consists of that pattern, it is assumed to be English.")
    (defun google-translate-enja-or-jaen (&optional initial-text)
      "Translate the region, sentence, or a given text between English and Japanese.

Replaces newlines with spaces to treat the text as a single sentence.
When called with a prefix argument (C-u), prompt for input in the minibuffer."
      (interactive
       ;; Define the interactive behavior in a list form for clarity.
       (list (cond ((use-region-p)
                    ;; If a region is active, use its content as the argument.
                    (buffer-substring-no-properties (region-beginning) (region-end)))
                   (current-prefix-arg
                    ;; If a prefix arg is supplied (C-u), prompt for the string to translate.
                    (read-string "Google Translate (en/ja): ")))))

      ;; Use let* to bind variables sequentially, making the data flow clear.
      (let* (
             ;; 1. Determine the target text to translate.
             (target-text
              (or initial-text ; Use the text from the interactive call if available.
                  ;; Otherwise, get the sentence at the current point.
                  (save-excursion
                    (thing-at-point 'sentence))))

             ;; 2. Pre-process the text (replace newlines with spaces).
             (processed-text (replace-regexp-in-string "\n" " " target-text))

             ;; 3. Detect the source language.
             (english-p (string-match-p "\\`[[:ascii:]]+\\'" processed-text))
             (source-lang (if english-p "en" "ja"))
             (target-lang (if english-p "ja" "en")))

        ;; 4. Execute the translation.
        (deactivate-mark) ; Deactivate the mark before displaying the translation.
        (google-translate-translate source-lang target-lang processed-text))))
  (leaf help
    :config (temp-buffer-resize-mode t))
  (leaf hideshow
    :bind ((:hs-minor-mode-map
            ("C-c C-M-c" . hs-toggle-hiding)
            ("C-c h"     . hs-toggle-hiding)
            ("C-c l"     . hs-hide-level))))
  (leaf persistent-scratch
    :defun persistent-scratch-setup-default
    :custom `(persistent-scratch-save-file . ,(locate-user-emacs-file ".scratch.el"))
    :config
    (with-current-buffer "*scratch*"
      (emacs-lock-mode 'kill))
    (persistent-scratch-setup-default))
  (leaf projectile
    :bind (("M-t" . projectile-command-map))
    :global-minor-mode t
    :custom (projectile-enable-caching . t)
    :blackout projectile-mode)
  (leaf rainbow-delimiters
    :doc "Highlight delimiters such as parentheses, brackets or braces according to their depth."
    :hook (prog-mode-hook . rainbow-delimiters-mode))
  (leaf so-long
    :doc "Say farewell to performance problems with minified code."
    :tag "builtin"
    :added "2024-08-24"
    :custom ((global-so-long-mode . t)))
  (leaf *skk
    :config
    (let*
        ((home (getenv "HOME"))
         (xdg-config-home (getenv "XDG_CONFIG_HOME"))
         (skk-nix-directory (expand-file-name ".nix-profile/share/skk/" home))
         (skk-user-directory (expand-file-name "ddskk" xdg-config-home))

         ;; List of dictionary files to use
         (skk-dictionary-files
          '("SKK-JISYO.L.utf8"
            "SKK-JISYO.itaiji.utf8"
            "SKK-JISYO.jinmei.utf8"
            "SKK-JISYO.fullname.utf8"
            "SKK-JISYO.propernoun.utf8"
            "SKK-JISYO.geo.utf8"
            "SKK-JISYO.station.utf8"
            "SKK-JISYO.okinawa.utf8"
            "SKK-JISYO.china_taiwan.utf8"
            "SKK-JISYO.office.zipcode.utf8"
            "SKK-JISYO.zipcode.utf8"))

         ;; Generate dictionary file list
         (skk-extra-jisyo-file-list
          (mapcar (lambda (filename)
                    (cons (expand-file-name filename skk-nix-directory) 'utf-8))
                  skk-dictionary-files)))

      ;; Main SKK configuration
      (leaf skk
        :defun skk-save-jisyo
        :bind* (("C-x C-j" . skk-mode)
                ("C-x t" . nil)
                ("C-x j" . nil))

        :custom
        ;; Basic settings
        ((default-input-method . "japanese-skk")
         (skk-user-directory . skk-user-directory)
         (skk-jisyo-code . 'utf-8)

         ;; Display and UI settings
         (skk-japanese-message-and-error . t)
         (skk-kutouten-type . 'jp)
         (skk-show-annotation . t)

         ;; Conversion and learning settings
         (skk-count-private-jisyo-candidates-exactly . t)
         (skk-share-private-jisyo . t)
         (skk-henkan-strict-okuri-precedence . t)
         (skk-check-okurigana-on-touroku . 'auto)
         (skk-search-sagyo-henkaku . t)

         ;; Search settings
         (skk-isearch-start-mode . 'latin)

         ;; Dictionary file settings (from Nix)
         (skk-extra-jisyo-file-list . skk-extra-jisyo-file-list))

        :config
        ;; Auto-save dictionary settings (6-second interval)
        (let ((auto-save-interval 6))
          (run-with-idle-timer auto-save-interval t
                               #'(lambda () (skk-save-jisyo +1))))))

    ;; SKK posframe configuration (popup display for conversion candidates)
    (leaf ddskk-posframe
      :doc "Show Henkan tooltip for ddskk via posframe"
      :after skk
      :custom ((ddskk-posframe-mode . t))
      :blackout ddskk-posframe-mode))
  (leaf topsy
    :doc "Simple sticky header"
    :req "emacs-26.3"
    :tag "convenience" "emacs>=26.3"
    :url "https://github.com/alphapapa/topsy.el"
    :added "2022-12-24"
    :emacs>= 26.3
    :hook (prog-mode-hook .  topsy-mode))
  (leaf undo-fu-session
    :global-minor-mode undo-fu-session-global-mode)
  (leaf vundo
    :bind (("C-x u" . vundo))))

(leaf *major-modes
  :config
  (leaf cc-mode
    :defun c-toggle-auto-hungry-state
    :preface
    (defun elim:c-mode-common-hook-func ()
      (c-set-style "bsd")
      (set-variable 'indent-tabs-mode nil)
      (set-variable 'c-basic-offset 2)
      (c-toggle-auto-hungry-state -1)
      (subword-mode 1))
    :hook ((c-mode-common-hook . elim:c-mode-common-hook-func)))
  (leaf css-mode
    :custom ((css-indent-offset . 2)))
  (leaf dockerfile-mode)
  (leaf elisp-mode
    :hook (emacs-lisp-mode-hook . elim:emacs-lisp-mode-hook-func)
    :config
    (defun elim:emacs-lisp-mode-hook-func ()
      (set-variable 'indent-tabs-mode nil)
      (hs-minor-mode +1)))
  (leaf elisp-slime-nav
    :hook ((emacs-lisp-mode-hook
            lisp-interaction-mode-hook
            ielm-mode-hook) .  elisp-slime-nav-mode))
  (leaf feature-mode
    :after org org-table)
  (leaf go-mode
    :preface
    (defun elim:go-mode-hook-func ()
      (set (make-local-variable 'tab-width) 4))
    :hook (go-mode-hook . elim:go-mode-hook-func))
  (leaf html-ts-mode :mode "\\.html?\\'")
  (leaf js
    :custom ((js-indent-level . 2)))
  (leaf json-mode)
  (leaf magit
    :bind (("C-x v s" . magit-status)
           ("C-x v f" . magit-diff-buffer-file))
    :custom (magit-diff-refine-hunk . 'all)
    :hook (git-commit-setup-hook . elim:git-commit-setup-hook-func)
    :init (add-to-list 'process-coding-system-alist '("git" utf-8 . utf-8))
    :config
    (defun elim:git-commit-setup-hook-func ()
      (flyspell-mode +1)
      (set (make-local-variable
            'elim:auto-delete-trailing-whitespace-enable-p) nil))
    :blackout auto-revert-mode)
  (leaf markdown-mode
    :mode (("\\.md\\'" "\\ISSUE_EDITMSG\\'") . gfm-mode)
    :bind (:markdown-mode-map
           ("<S-tab>" . markdown-shifttab)
           ("C-c 1"   . markdown-insert-header-atx-1)
           ("C-c 2"   . markdown-insert-header-atx-2)
           ("C-c b"   . markdown-insert-bold)
           ("C-c i"   . markdown-insert-italic))
    :custom
    ((markdown-asymmetric-header            . t)
     (markdown-fontify-code-blocks-natively . t)
     (markdown-gfm-use-electric-backquote   . nil)
     (markdown-header-scaling               . nil)
     (markdown-hr-strings                   . '("* * *\n\n"))
     (markdown-marginalize-headers          . nil)))
  (leaf nix-mode
    :doc "Major mode for editing .nix files"
    :req "emacs-25.1" "magit-section-0" "transient-0.3"
    :tag "unix" "tools" "languages" "nix" "emacs>=25.1"
    :url "https://github.com/NixOS/nix-mode"
    :added "2023-03-28"
    :emacs>= 25.1
    :after magit-section)
  (leaf org :require org org-table)
  (leaf *ruby
    :config
    (leaf rubocop)
    (leaf ruby-end)
    (leaf ruby-mode
      :bind (:ruby-mode-map
             ("C-m" . reindent-then-newline-and-indent))
      :custom ((ruby-deep-indent-paren-style . nil)
               (ruby-flymake-use-rubocop-if-available . nil)
               (ruby-insert-encoding-magic-comment . nil)))
    (leaf rspec-mode))
  (leaf sh-script
    :mode ("\\.env\\'" "\\.env.sample\\'")
    :custom ((sh-basic-offset . 2)
             (sh-indentation . 2)))
  (leaf slim-mode)
  (leaf text-mode
    :preface
    (defun elim:text-mode-hook-func ()
      (set-variable 'indent-tabs-mode nil))
    :hook (text-mode-hook . elim:text-mode-hook-func))
  (leaf terraform-mode)
  (leaf tsx-ts-mode :mode "\\.tsx\\'")
  (leaf yaml-mode))

(provide 'init)

;;; init.el ends here
