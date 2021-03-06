

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(auto-compression-mode t nil (jka-compr))
 '(case-fold-search t)
 '(column-number-mode t)
 '(current-language-environment "UTF-8")
 '(default-input-method "rfc1345")
 '(global-font-lock-mode t nil (font-lock))
 '(package-selected-packages
   (quote
    (vlf whitespace-cleanup-mode json-mode csv-mode clang-format)))
 '(show-paren-mode t nil (paren))
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:stipple nil :background "#141312" :foreground "#ffffff" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 98 :width normal :family "DejaVu Sans Mono" :foundry "PfEd")))))

(setq inhibit-startup-message t)
(setq initial-scratch-message nil)
;;===================================
;;Adjust the backspace, delete keys
;; Ctrl-Left and Ctrl-Right
;;===================================
(cond 
 (window-system 
  (normal-erase-is-backspace-mode 1)
  (tool-bar-mode 0)) ; Disable toolbar
 (t ; If it is in text mode
  (global-set-key "\M-[1;5C"    'forward-word)         ; Ctrl+right   => forward word
  (global-set-key "\M-[1;5D"    'backward-word)        ; Ctrl+left    => backward word
  (global-set-key "\M-[1;5B"    'forward-paragraph)    ; Ctrl+down   => forward paragraph
  (global-set-key "\M-[1;5A"    'backward-paragraph)   ; Ctrl+up     => backward paragraph
  )
 )


;;===================================
;;Show columns numbers
;;===================================
(setq column-number-mode t)

;;===================================
;;Highlight lines
;;===================================
(setq transient-mark-mode t)


;;===================================
;; Wheel mouse
;;===================================
(defun up-slightly () (interactive) (scroll-up 7))
(defun down-slightly () (interactive) (scroll-down 7))
(global-set-key [mouse-4] 'down-slightly)
(global-set-key [mouse-5] 'up-slightly)

(defun up-one () (interactive) (scroll-up 1))
(defun down-one () (interactive) (scroll-down 1))
(global-set-key [S-mouse-4] 'down-one)
(global-set-key [S-mouse-5] 'up-one)

(defun up-a-lot () (interactive) (scroll-up))
(defun down-a-lot () (interactive) (scroll-down))
(global-set-key [C-mouse-4] 'down-a-lot)
(global-set-key [C-mouse-5] 'up-a-lot)

;;====================================
;; Adjust problems when in window mode
;;====================================
(cond 
 (window-system 
  (setq x-select-enable-clipboard t)
  (setq x-select-enable-clipboard-manager t)
  (setq interprogram-paste-function 'x-cut-buffer-or-selection-value))
 )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; backup settings                                                        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; https://www.emacswiki.org/emacs/BackupFiles
(setq
 backup-by-copying t     ; don't clobber symlinks
 kept-new-versions 2     ; keep 10 latest versions
 kept-old-versions 0     ; don't bother with old versions
 delete-old-versions t   ; don't ask about deleting old versions
 version-control t       ; number backups
 vc-make-backup-files t) ; backup version controlled files

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; backup every save                                                      ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; http://stackoverflow.com/questions/151945/how-do-i-control-how-emacs-makes-backup-files
;; https://www.emacswiki.org/emacs/backup-each-save.el
(defvar bjm/backup-file-size-limit (* 5 1024 1024)
  "Maximum size of a file (in bytes) that should be copied at each savepoint.

If a file is greater than this size, don't make a backup of it.
Default is 5 MB")

(defvar bjm/backup-location (expand-file-name (concat "~/.emacs-" (user-login-name)))
  "Base directory for backup files.")

(defvar bjm/backup-trash-dir (expand-file-name (concat "~/.emacs-" (user-login-name) "/trash"))
  "Directory for unwanted backups.")

(defvar bjm/backup-exclude-regexp "\\[dasdasdasdadssdaase\\]"
  "Don't back up files matching this regexp.

Files whose full name matches this regexp are backed up to `bjm/backup-trash-dir'. Set to nil to disable this.")

;; Default and per-save backups go here:
;; N.B. backtick and comma allow evaluation of expression
;; when forming list
(setq backup-directory-alist
      `(("" . ,(expand-file-name "per-save" bjm/backup-location))))

;; add trash dir if needed
(if bjm/backup-exclude-regexp
    (add-to-list 'backup-directory-alist `(,bjm/backup-exclude-regexp . ,bjm/backup-trash-dir)))

(defun bjm/backup-every-save ()
  "Backup files every time they are saved.

Files are backed up to `bjm/backup-location' in subdirectories \"per-session\" once per Emacs session, and \"per-save\" every time a file is saved.

Files whose names match the REGEXP in `bjm/backup-exclude-regexp' are copied to `bjm/backup-trash-dir' instead of the normal backup directory.

Files larger than `bjm/backup-file-size-limit' are not backed up."

  ;; Make a special "per session" backup at the first save of each
  ;; emacs session.
  (when (not buffer-backed-up)
    ;;
    ;; Override the default parameters for per-session backups.
    ;;
    (let ((backup-directory-alist
           `(("." . ,(expand-file-name "per-session" bjm/backup-location))))
          (kept-new-versions 3))
      ;;
      ;; add trash dir if needed
      ;;
      (if bjm/backup-exclude-regexp
          (add-to-list
           'backup-directory-alist
           `(,bjm/backup-exclude-regexp . ,bjm/backup-trash-dir)))
      ;;
      ;; is file too large?
      ;;
      (if (<= (buffer-size) bjm/backup-file-size-limit)
          (progn
            (message "Made per session backup of %s" (buffer-name))
            (backup-buffer))
        (message "WARNING: File %s too large to backup - increase value of bjm/backup-file-size-limit" (buffer-name)))))
  ;;
  ;; Make a "per save" backup on each save.  The first save results in
  ;; both a per-session and a per-save backup, to keep the numbering
  ;; of per-save backups consistent.
  ;;
  (let ((buffer-backed-up nil))
    ;;
    ;; is file too large?
    ;;
    (if (<= (buffer-size) bjm/backup-file-size-limit)
        (progn
          (message "Made per save backup of %s" (buffer-name))
          (backup-buffer))
      (message "WARNING: File %s too large to backup - increase value of bjm/backup-file-size-limit" (buffer-name)))))

;; add to save hook
(add-hook 'before-save-hook 'bjm/backup-every-save)


;;====================================
;; Customized functions
;;====================================
;; Removing new lines in a region
(defun remove-newlines-in-region ()
  "Removes all newlines in the region."
  (interactive)
  (save-restriction
    (narrow-to-region (point) (mark))
    (goto-char (point-min))
    (while (search-forward "\n" nil t) (replace-match " " nil t))))


;; Set current window width to n columns
(defun set-window-width (n)
  "Set the selected window's width."
  (cond ((<= ( - (- (frame-width) 10) n) 0) (prin1 "Frame width too narrow")) 
	(t (enlarge-window-horizontally (- n (window-width))))))

;; Set current window width to 80 columns
(defun set-80-columns ()
  "Set the selected window to 80 columns."
  (interactive)
  (set-window-width 80))

;; Apache develop mode
(defun apache-mode ()
  (interactive)
  (message "Toggling to Apache mode")
  (setq tab-width 4)
  (setq c-basic-offset 4)
  (setq indent-tabs-mode nil))

;; Firmware develop mode
(defun firmware-mode ()
  (interactive)
  (message "Toggling to Firmware mode")
  (setq tab-width 2)
  (setq c-basic-offset 2)
  (setq indent-tabs-mode nil))

(setq clang-format-style "Google")
;;====================================
;; Customized Keys
;;====================================
(global-set-key "\C-ca" 'apache-mode)
(global-set-key "\C-cc" 'compare-windows)
(global-set-key "\C-cf" 'firmware-mode)
(global-set-key "\C-cl" 'goto-line)
(global-set-key "\C-cr" 'revert-buffer)
(global-set-key "\C-ct" 'toggle-truncate-lines)
(global-set-key "\C-cw" 'set-80-columns)
(global-set-key "\C-cq" 'remove-newlines-in-region)
;; <C-c tab> for clang-format-region
(global-set-key [3 9] 'clang-format-region)
(global-set-key "\C-l" 'delete-region)
;; Back window function
(defun back-window () (interactive) (other-window -1))
(global-set-key "\C-co" 'back-window)





(setq frame-title-format (list "%b-" user-login-name "@" system-name))

;;====================================
;; Enabling Thesaurus
;;====================================
;;(require 'thesaurus)
;;(setq thesaurus-bhl-api-key "feb383ff6e1617ced9e71a464ca4b692")  ;; from registration
;; optional key binding
;;(define-key global-map (kbd "C-x t") 'thesaurus-choose-synonym-and-replace)


;;====================================
;; Enabling HideShow
;;====================================
(load-library "hideshow")
(add-hook 'vhdl-mode-hook 'hs-minor-mode)
(add-hook 'c-mode-hook 'hs-minor-mode)
(add-hook 'c++-mode-hook 'hs-minor-mode)
(add-hook 'java-mode-hook 'hs-minor-mode)
(add-hook 'perl-mode-hook 'hs-minor-mode)
(add-hook 'emacs-lisp-mode-hook 'hs-minor-mode)
(add-hook 'LaTeX-mode-hook  'hs-minor-mode)
;;HideShow shortcuts
;;C-c @ C-h    Hide the current block (hs-hide-block).
;;C-c @ C-s    Show the current block (hs-show-block).
;;C-c @ C-c    Either hide or show the current block (hs-toggle-hiding).
;;S-Mouse-2    Either hide or show the block you click on 
;;             (hs-mouse-toggle-hiding).
;;C-c @ C-M-h    Hide all top-level blocks (hs-hide-all).
;;C-c @ C-M-s    Show everything in the buffer (hs-show-all).
;;C-c @ C-l    Hide all blocks n levels below this block (hs-hide-level).
(require 'xcscope)
(cscope-setup)
;; Disable cscope update database by default
(setq cscope-option-do-not-update-database 1)

(setq auto-mode-alist (cons '("\\.cl$" . c-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.h$" . c++-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.tex$" . latex-mode) auto-mode-alist))

;;(require 'iso-acc)
;;(require 'iso-insert) 
;;(iso-accents-customize "portuguese")
(require 'ess-site)

;; Download package from: 
;;  https://raw.githubusercontent.com/nschum/macro-math.el/master/macro-math.el
;;(require 'macro-math)
;;(global-set-key "\C-x~" 'macro-math-eval-and-round-region)
;;(global-set-key "\C-x=" 'macro-math-eval-region)


(c-add-style "my-style"
             '("stroustrup"
	       (indent-tabs-mode . nil)        ; use spaces rather than tabs
	       (c-basic-offset . 2)            ; indent by four spaces
	       (c-offsets-alist . ((inline-open . 0)  ; custom indentation rules
                                   (brace-list-open . 0)
                                   (statement-case-open . +)
				   (access-label . [1])))))
(defun my-c++-mode-hook ()
  (c-set-style "my-style")        ; use my-style defined above
  (c-set-offset 'innamespace [0])
  (c-set-offset 'case-label '+)
  (c-toggle-auto-hungry-state 0))

(defun my-c-mode-hook ()
  (c-set-style "my-style")        ; use my-style defined above
  (c-set-offset 'case-label '+))

(add-hook 'c-mode-common-hook 'my-c-mode-hook)
(add-hook 'c++-mode-hook 'my-c++-mode-hook)


;; Enable MATLAB
;;(add-to-list 'load-path "~/util/matlab-mode")
;;(load-library "matlab-load")

;; ==================================================
;; Tweaks for ediff
;; ==================================================
(defun command-line-diff (switch)
  (let ((file1 (pop command-line-args-left))
        (file2 (pop command-line-args-left)))
    (ediff file1 file2)))

(add-to-list 'command-switch-alist '("diff" . command-line-diff))
;; Usage: emacs -diff file1 file2

;; saner ediff default
(setq ediff-diff-options "-w")
(setq ediff-split-window-function 'split-window-horizontally)
(setq ediff-window-setup-function 'ediff-setup-windows-plain)
(add-hook 'ediff-before-setup-hook 'new-frame)
(add-hook 'ediff-quit-hook 'delete-frame)

;; ==================================================
;; Enable MELPA repository
;; ==================================================
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)

(require 'ansi-color)
(defun display-ansi-colors ()
  (interactive)
    (ansi-color-apply-on-region (point-min) (point-max)))

;; ==================================================
;; Highight portion of lines that are longer than 80 columns
;; ==================================================
(require 'whitespace)
(setq whitespace-line-column 80) ;; limit line length
(setq whitespace-style '(face lines-tail tabs))
;;(setq whitespace-style '(face tabs))

(add-hook 'prog-mode-hook 'whitespace-mode)

;; ==================================================
;; Handle big files
;; ==================================================
(require 'vlf-setup)
