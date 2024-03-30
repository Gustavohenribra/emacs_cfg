(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(eval-and-compile
  (customize-set-variable
   'package-archives '(("org" . "https://orgmode.org/elpa/")
                       ("melpa" . "https://melpa.org/packages/")
                       ("gnu" . "https://elpa.gnu.org/packages/")))
  (package-initialize)
  (unless (package-installed-p 'use-package)
    (package-refresh-contents)
    (package-install 'use-package)))

;; Esc quit
(global-set-key (kbd "<escape>")      'keyboard-escape-quit)

;; Windows undo/redo
(unless (package-installed-p 'undo-tree)
  (package-install 'undo-tree))
(require 'undo-tree)
(setq undo-tree-auto-save-history t)
(setq undo-tree-history-directory-alist
      '(("." . "~/.emacs.d/undo/")))
(global-undo-tree-mode)

(global-set-key (kbd "C-z") 'undo-tree-undo)
(global-set-key (kbd "C-S-z") 'undo-tree-redo)

;; Move text
(move-text-default-bindings)
(defun indent-region-advice (&rest ignored)
  (let ((deactivate deactivate-mark))
    (if (region-active-p)
        (indent-region (region-beginning) (region-end))
      (indent-region (line-beginning-position) (line-end-position)))
    (setq deactivate-mark deactivate)))

(advice-add 'move-text-up :after 'indent-region-advice)
(advice-add 'move-text-down :after 'indent-region-advice)

;; Appearance
(set-frame-font "Hack-14" nil t)
(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)
(column-number-mode 1)
(show-paren-mode 1)
(setq inhibit-startup-screen t)
(add-to-list 'initial-frame-alist '(fullscreen . maximized))
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
(load-theme 'pastels-on-dark t)
(set-language-environment "UTF-8")

;; General settings
(delete-selection-mode t)
(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024)) ;; 1mb
(setq auto-save-default nil)
(setq make-backup-files nil)
(setq create-lockfiles nil)
(global-display-line-numbers-mode)
(setq display-line-numbers-type 'relative)

;; Jump to relative line
(defun goto-relative-line (offset)
  "Go to a relative line specified by OFFSET."
  (interactive "NRelative line offset: ")
  (goto-line (+ (line-number-at-pos) offset)))

(global-set-key (kbd "C-c g") 'goto-relative-line)

;;Doom theme
(use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-gruvbox t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; or for treemacs users
  (setq doom-themes-treemacs-theme "doom-atom") ; use "doom-colors" for less minimal icon theme
  (doom-themes-treemacs-config))

;; Doom mode line
(setq doom-modeline-unicode-fallback nil)
(setq doom-modeline-buffer-name t)

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))

;; Ivy & Swiper
(use-package swiper
  :ensure t
  :bind
  (("C-s" . swiper)))

(use-package ivy
  :ensure t
  :config
  (ivy-mode 1))

;; Amx
(amx-mode 1)

;; Marginalia
(use-package marginalia
  :ensure t
  :config
  (marginalia-mode 1))

;; Which-key
(use-package which-key
  :ensure t
  :config
  (which-key-mode))

;; json-mode
(use-package json-mode
  :ensure t)

;; Company
(add-hook 'after-init-hook 'global-company-mode)
(global-set-key (kbd "C-SPC") 'company-complete)
(setq company-idle-delay 0)
(setq company-minimum-prefix-length 1)
(setq company-selection-wrap-around t)

;; Lsp
(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook
  ((python-mode . lsp))
  :init
  (setq lsp-keymap-prefix "C-c l")  ;; Or 'C-l', 's-l'
  :config
  (lsp-enable-which-key-integration t))

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode))
(setq lsp-ui-doc-enable nil)
(setq lsp-ui-sideline-enable nil)
(setq lsp-ui-sideline-show-hover nil)
(setq lsp-signature-render-documentation nil)
(global-set-key (kbd "M-d ") 'lsp-ui-doc-show)

(use-package lsp-treemacs
  :after lsp)

(global-set-key (kbd "C-c f") 'flymake-show-buffer-diagnostics)

(use-package web-mode  :ensure t
  :mode (("\\.js\\'" . web-mode)
         ("\\.jsx\\'" . web-mode)
         ("\\.ts\\'" . web-mode)
         ("\\.tsx\\'" . web-mode)
         ("\\.html\\'" . web-mode)
         ("\\.vue\\'" . web-mode)
	 ("\\.json\\'" . web-mode))
  :commands web-mode
  :hook (web-mode . lsp-deferred)
  :config
  (setq web-mode-content-types-alist
	'(("jsx" . "\\.js[x]?\\'")))
  )

;; Multiple cursors
(global-set-key (kbd "C-c m") 'mc/edit-lines)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)

;; Helpful
(global-set-key (kbd "C-h f") #'helpful-callable)
(global-set-key (kbd "C-h v") #'helpful-variable)
(global-set-key (kbd "C-h k") #'helpful-key)
(global-set-key (kbd "C-h x") #'helpful-command)
(global-set-key (kbd "C-c C-S-d") #'helpful-at-point)
(global-set-key (kbd "C-h F") #'helpful-function)
;; Search for a function or class = C-M-.

;; Project
(require 'project)
(global-set-key (kbd "C-x p f") #'project-find-file)

;; 

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("e3daa8f18440301f3e54f2093fe15f4fe951986a8628e98dcd781efbec7a46f2" "c1d5759fcb18b20fd95357dcd63ff90780283b14023422765d531330a3d3cec2" "8c7e832be864674c220f9a9361c851917a93f921fedb7717b1b5ece47690c098" "aec7b55f2a13307a55517fdf08438863d694550565dee23181d2ebd973ebd6b8" "13096a9a6e75c7330c1bc500f30a8f4407bd618431c94aeab55c9855731a95e1" "8b148cf8154d34917dfc794b5d0fe65f21e9155977a36a5985f89c09a9669aa0" "4ade6b630ba8cbab10703b27fd05bb43aaf8a3e5ba8c2dc1ea4a2de5f8d45882" "4e2e42e9306813763e2e62f115da71b485458a36e8b4c24e17a2168c45c9cf9d" "dccf4a8f1aaf5f24d2ab63af1aa75fd9d535c83377f8e26380162e888be0c6a9" "b5fd9c7429d52190235f2383e47d340d7ff769f141cd8f9e7a4629a81abc6b19" "014cb63097fc7dbda3edf53eb09802237961cbb4c9e9abd705f23b86511b0a69" "5a3e8b5b5f4562c2b5e6d3f8ea1bfe3edc2af0550c526ef4b215cf735b896713" default))
 '(package-selected-packages
   '(auto-virtualenv amx ag multiple-cursors all-the-icons apheleia magit company helpful move-text use-package marginalia vertico undo-tree)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
