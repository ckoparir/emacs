;;; initfile --- Summary:
;;; Commentary:
;; Emacs 24.5.1
;; Many places were referenced in constructing this file.  Here are some:
;; http://aaronbedra.com/emacs.d/
;; https://github.com/atilaneves/cmake-ide
;; http://stackoverflow.com/questions/13825188/suppress-c-namespace-indentation-in-emacs
;; http://syamajala.github.io/c-ide.html
;; http://tuhdo.github.io/c-ide.html
;; http://tuhdo.github.io/helm-intro.html
;; https://github.com/AndreaCrotti/yasnippet-snippets
;;; Code:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start emacs server
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(server-start)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Mac OS X Tweaks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Add these to the PATH so that proper executables are found
;; This is probably just for Mac OS
(setenv "PATH" (concat (getenv "PATH") ":/usr/texbin"))
(setenv "PATH" (concat (getenv "PATH") ":/usr/bin"))
(setenv "PATH" (concat (getenv "PATH") ":/usr/local/bin"))
(setq exec-path (append exec-path '("/usr/texbin")))
(setq exec-path (append exec-path '("/usr/bin")))
(setq exec-path (append exec-path '("/usr/local/bin")))

;; We don't want to type yes and no all the time so, do y and n
(defalias 'yes-or-no-p 'y-or-n-p)
;; Disable the horrid auto-save
(setq auto-save-default nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set packages to install
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
;; (package-initialize)
(require 'package) ;; You might already have this line
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(when (< emacs-major-version 24)
  ;; For important compatibility libraries like cl-lib
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))
;; You might already have this line
(package-initialize)

;; Path definition for themes and packages will be installed
(let ((default-directory  "~/.emacs.d/lisp/"))
  (setq load-path
        (append
         (let ((load-path  (copy-sequence load-path))) ;; Shadow
           (normal-top-level-add-subdirs-to-load-path))
         load-path)))

;; list the packages you want
(defvar package-list)
(setq package-list '(async auctex auto-complete autopair clang-format cmake-ide
                           cmake-mode company company-irony
                           company-irony-c-headers dash epl flycheck
                           flycheck-irony flycheck-pyflakes
                           google-c-style helm helm-core helm-ctest
                           helm-flycheck helm-flyspell helm-ls-git helm-ls-hg
                           hungry-delete irony
                           let-alist levenshtein markdown-mode pkg-info
                           popup rtags seq solarized-theme vlf web-mode
                           window-numbering writegood-mode yasnippet))
;; fetch the list of packages available
(unless package-archive-contents
  (package-refresh-contents))
;; install the missing packages
(dolist (package package-list)
  (unless (package-installed-p package)
    (package-install package)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Configure flycheck
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; If for some reason you're not using CMake you can use a tool like
;; bear (build ear) to get a compile_commands.json file in the root
;; directory of your project. flycheck can use this as well to figure
;; out how to build your project. If that fails, you can also
;; manually include directories by add the following into a
;; ".dir-locals.el" file in the root directory of the project. You can
;; set any number of includes you would like and they'll only be
;; used for that project. Note that flycheck calls
;; "cmake CMAKE_EXPORT_COMPILE_COMMANDS=1 ." so if you should have
;; reasonable (working) defaults for all your CMake variables in
;; your CMake file.
;; (setq flycheck-clang-include-path (list "/path/to/include/" "/path/to/include2/"))
;;
;; With CMake, you might need to pass in some variables since the defaults
;; may not be correct. This can be done by specifying cmake-compile-command
;; in the project root directory. For example, I need to specify CHARM_DIR
;; and I want to build in a different directory (out of source) so I set:
;; ((nil . ((cmake-ide-build-dir . "../ParBuild/"))))
;; ((nil . ((cmake-compile-command . "-DCHARM_DIR=/Users/nils/SpECTRE/charm/"))))
;; You can also set arguments to the C++ compiler, I use clang so:
;; ((nil . ((cmake-ide-clang-flags-c++ . "-I/Users/nils/SpECTRE/Amr/"))))
;;
;; You can force cmake-ide-compile to compile in parallel by changing:
;; "make -C " to "make -j8 -C " in the cmake-ide.el file and then force
;; recompiling the directory using M-x byte-force-recompile
;; Require flycheck to be present
(require 'flycheck)
;; Force flycheck to always use c++11 support. We use
;; the clang language backend so this is set to clang
(add-hook 'c++-mode-hook
          (lambda ()
            (setq flycheck-clang-language-standard "c++14")
            )
          )
;; Turn flycheck on everywhere
(global-flycheck-mode)

;; Use flycheck-pyflakes for python. Seems to work a little better.
(require 'flycheck-pyflakes)

;; Load rtags and start the cmake-ide-setup process
(require 'rtags)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Setup cmake-ide
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'cmake-ide)
(cmake-ide-setup)
;; Set cmake-ide-flags-c++ to use C++14
(setq cmake-ide-flags-c++ (append '("-std=c++14")))
;; We want to be able to compile with a keyboard shortcut
(global-set-key (kbd "C-c m") 'cmake-ide-compile)

;; Set rtags to enable completions and use the standard keybindings.
;; A list of the keybindings can be found at:
;; http://syamajala.github.io/c-ide.html
(setq rtags-autostart-diagnostics t)
(rtags-diagnostics)
(setq rtags-completions-enabled t)
(rtags-enable-standard-keybindings)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set up helm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load helm and set M-x to helm, buffer to helm, and find files to herm
(require 'helm-config)
(require 'helm)
(require 'helm-ls-git)
(require 'helm-ctest)
;; Use C-c h for helm instead of C-x c
(global-set-key (kbd "C-c h") 'helm-command-prefix)
(global-unset-key (kbd "C-x c"))
(global-set-key (kbd "M-x") 'helm-M-x)
(global-set-key (kbd "C-x b") 'helm-mini)
(global-set-key (kbd "C-x C-b") 'helm-buffers-list)
(global-set-key (kbd "C-x C-f") 'helm-find-files)
(global-set-key (kbd "C-c t") 'helm-ctest)
(setq helm-split-window-in-side t
                                        ; open helm buffer inside current window,
                                        ; not occupy whole other window
 helm-move-to-line-cycle-in-source t
                                        ; move to end or beginning of source when
                                        ; reaching top or bottom of source.
 helm-ff-search-library-in-sexp t
                                        ; search for library in `require' and `declare-function' sexp.
 helm-scroll-amount 8
                                        ; scroll 8 lines other window using M-<next>/M-<prior>
 helm-ff-file-name-history-use-recentf t
 ;; Allow fuzzy matches in helm semantic
 helm-semantic-fuzzy-match t
 elm-imenu-fuzzy-match t
 )
;; Have helm automaticaly resize the window
(helm-autoresize-mode 1)
(setq rtags-use-helm t)
(require 'helm-flycheck) ;; Not necessary if using ELPA package
(eval-after-load 'flycheck
  '(define-key flycheck-mode-map (kbd "C-c ! h") 'helm-flycheck))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set up code completion with company and irony
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'company)
(require 'company-rtags)
(global-company-mode)

;; Enable semantics mode for auto-completion
(require 'cc-mode)
(require 'semantic)
(global-semanticdb-minor-mode 1)
(global-semantic-idle-scheduler-mode 1)
(semantic-mode 1)

;; Setup irony-mode to load in c-modes
(require 'irony)
(require 'company-irony-c-headers)
(require 'cl)
(add-hook 'c++-mode-hook 'irony-mode)
(add-hook 'c-mode-hook 'irony-mode)
(add-hook 'objc-mode-hook 'irony-mode)

;; irony-mode hook that is called when irony is triggered
(defun my-irony-mode-hook ()
  "Custom irony mode hook to remap keys."
  (define-key irony-mode-map [remap completion-at-point]
    'irony-completion-at-point-async)
  (define-key irony-mode-map [remap complete-symbol]
    'irony-completion-at-point-async))

(add-hook 'irony-mode-hook 'my-irony-mode-hook)
(add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)

;; company-irony setup, c-header completions
(add-hook 'irony-mode-hook 'company-irony-setup-begin-commands)
;; Remove company-semantic because it has higher precedance than company-clang
;; Using RTags completion is also faster than semantic, it seems. Semantic
;; also provides a bunch of technically irrelevant completions sometimes.
;; All in all, RTags just seems to do a better job.
(setq company-backends (delete 'company-semantic company-backends))
;; Enable company-irony and several other useful auto-completion modes
;; We don't use rtags since we've found that for large projects this can cause
;; async timeouts. company-semantic (after company-clang!) works quite well
;; but some knowledge some knowledge of when best to trigger is still necessary.
(eval-after-load 'company
  '(add-to-list
    'company-backends '(company-irony-c-headers
                        company-irony company-yasnippet
                        company-clang company-rtags)
    )
  )

(defun my-disable-semantic ()
  "Disable the company-semantic backend."
  (interactive)
  (setq company-backends (delete '(company-irony-c-headers
                                   company-irony company-yasnippet
                                   company-clang company-rtags
                                   company-semantic) company-backends))
  (add-to-list
   'company-backends '(company-irony-c-headers
                       company-irony company-yasnippet
                       company-clang company-rtags))
  )
(defun my-enable-semantic ()
  "Enable the company-semantic backend."
  (interactive)
  (setq company-backends (delete '(company-irony-c-headers
                                   company-irony company-yasnippet
                                   company-clang) company-backends))
  (add-to-list
   'company-backends '(company-irony-c-headers
                       company-irony company-yasnippet company-clang))
  )

;; Zero delay when pressing tab
(setq company-idle-delay 0)
(define-key c-mode-map [(tab)] 'company-complete)
(define-key c++-mode-map [(tab)] 'company-complete)
;; Delay when idle because I want to be able to think without
;; completions immediately being called and slowing me down.
(setq company-idle-delay 0.2)

;; Prohibit semantic from searching through system headers. We want
;; company-clang to do that for us.
(setq-mode-local c-mode semanticdb-find-default-throttle
                 '(local project unloaded recursive))
(setq-mode-local c++-mode semanticdb-find-default-throttle
                 '(local project unloaded recursive))

(semantic-remove-system-include "/usr/include/" 'c++-mode)
(semantic-remove-system-include "/usr/local/include/" 'c++-mode)
(add-hook 'semantic-init-hooks
          'semantic-reset-system-include)

;; rtags Seems to be really slow sometimes so I disable using
;; it with irony mode
;; (require 'flycheck-rtags)
;; (defun my-flycheck-rtags-setup ()
;;   (flycheck-select-checker 'rtags)
;;   ;; RTags creates more accurate overlays.
;;   (setq-local flycheck-highlighting-mode nil)
;;   (setq-local flycheck-check-syntax-automatically nil))
;; ;; c-mode-common-hook is also called by c++-mode
;; (add-hook 'c-mode-common-hook #'my-flycheck-rtags-setup)

;; (eval-after-load 'flycheck
;;   '(add-hook 'flycheck-mode-hook #'flycheck-irony-setup))

;; Add flycheck to helm
(require 'helm-flycheck) ;; Not necessary if using ELPA package
(eval-after-load 'flycheck
  '(define-key flycheck-mode-map (kbd "C-c ! h") 'helm-flycheck))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Window numbering
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package window-numbering installed from package list
;; Allows switching between buffers using meta-(# key)
(when (display-graphic-p)
  (window-numbering-mode t)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; C++ keys
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'cc-mode)
;; Compiling:
(define-key c-mode-base-map (kbd "C-c C-c") 'compile)
;; Change compilation command:
(setq compile-command "make -k")


;; Load glasses mode, which turns camel notation from
;; thisBullshitThatICantRead to
;; this_Bullshit_That_I_Cant_Read. Much better...
;; (add-hook 'c-mode-common-hook 'glasses-mode)

;; Change tab key behavior to insert spaces instead
(setq-default indent-tabs-mode nil)

;; Set the number of spaces that the tab key inserts (usually 2 or 4)
(setq c-basic-offset 2)
;; Set the size that a tab CHARACTER is interpreted as
;; (unnecessary if there are no tab characters in the file!)
(setq tab-width 4)
;; Set python tab width...
(setq-default tab-width 4)
(setq-default python-indent 2)
;; (setq-default python-indent-offset 0)
(add-hook 'python-mode-hook
          (lambda ()
            (setq tab-width 2)))

;; We want to be able to see if there is a tab character vs a space.
;; global-whitespace-mode allows us to do just that.
;; Set whitespace mode to only show tabs, not newlines/spaces.
(require 'whitespace)
(setq whitespace-style '(tabs tab-mark))
;; Turn on whitespace mode globally.
(global-whitespace-mode 1)

;; Enable Google style things
;; This prevents the extra two spaces in a namespace that Emacs
;; otherwise wants to put... Gawd!
(add-hook 'c-mode-common-hook 'google-set-c-style)

;; Autoindent using google style guide
(add-hook 'c-mode-common-hook 'google-make-newline-indent)

;; Enable hide/show of code blocks
(add-hook 'c-mode-common-hook 'hs-minor-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Clang-format
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; clang-format can be triggered using C-M-tab
;; (load "~/.emacs.d/clang-format.el")
(require 'clang-format)
(global-set-key [C-M-tab] 'clang-format-region)
;; Create clang-format file using google style
;; clang-format -style=google -dump-config > .clang-format

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Org-Mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (require 'org-mode-default)
(setq org-log-done 'time
      org-todo-keywords '((sequence "TODO" "INPROGRESS" "DONE"))
      org-todo-keyword-faces '(("INPROGRESS" . (:foreground "blue" :weight bold))))
(add-hook 'org-mode-hook
          (lambda ()
            (flyspell-mode)))
(add-hook 'org-mode-hook
          (lambda ()
            (writegood-mode)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; General Tweaks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; turn on highlight matching brackets when cursor is on one
(show-paren-mode 1)
;; Overwrite region selected
(delete-selection-mode t)
;; Show column numbers by default
(setq column-number-mode t)
;; Use CUA to delete selections
(setq cua-mode t)
(setq cua-enable-cua-keys nil)
;; Prevent emacs from creating a bckup file filename~
(setq make-backup-files nil)
;; Show date and time in modeline
(display-time)
;; Settings for searching
(setq-default case-fold-search nil ;case sensitive searches by default
              search-highlight t) ;hilit matches when searching
;; Highlight the line we are currently on
(global-hl-line-mode 1)
;; Disable the toolbar at the top since it's useless
(if (functionp 'tool-bar-mode) (tool-bar-mode -1))
;; Automatically at closing brace, bracket and quote
(require 'autopair)
(autopair-global-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load hungry Delete, caus we're lazy
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set hungry delete:
(require 'hungry-delete)
(global-hungry-delete-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Syntax Highlighting in GUDA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load CUDA mode so we get syntax highlighting in .cu files
;; (autoload 'cuda-mode "~/.emacs.d/plugins/cuda-mode.el")
;; (add-to-list 'auto-mode-alist '("\\.cu\\'" . cuda-mode))
;; (add-to-list 'auto-mode-alist '("\\.cuh\\'" . cuda-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Global Keyboard Shortcuts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set help to C-?
(global-set-key (kbd "C-?") 'help-command)
;; Set mark paragraph to M-?
(global-set-key (kbd "M-?") 'mark-paragraph)
;; Set backspace to C-h
(global-set-key (kbd "C-h") 'delete-backward-char)
;; Set backspace word to M-h
(global-set-key (kbd "M-h") 'backward-kill-word)
;; Use meta+tab word completion
(global-set-key (kbd "M-TAB") 'dabbrev-expand)
;; Easy undo key
(global-set-key (kbd "C-/") 'undo)
;; Comment or uncomment the region
(global-set-key (kbd "C-c ;") 'comment-or-uncomment-region)
;; Indent after a newline, if required by syntax of language
(global-set-key (kbd "C-m") 'newline-and-indent)
;; Load the compile ocmmand
(global-set-key (kbd "C-c C-c") 'compile)
;; Undo, basically C-x u
(global-set-key (kbd "C-/") 'undo)
;; Navigation shortcuts
(global-set-key (kbd "M-F") 'forward-char)
(global-set-key (kbd "M-B") 'backward-char)
(global-set-key (kbd "M-n") 'next-line)
(global-set-key (kbd "M-p") 'previous-line)
(global-set-key (kbd "M-D") 'delete-char)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Magit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(global-set-key (kbd "M-g M-s") 'magit-status)
(global-set-key (kbd "M-g M-c") 'magit-checkout)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; cmake-mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'cmake-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load c++-mode when opening charm++ interface files
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-to-list 'auto-mode-alist '("\\.ci\\'" . c++-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Appearance
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The deeper blue theme is loaded but the resulting text
;; appears black in Aquamacs. This can be fixed by setting
;; the font color under Menu Bar->Options->Appearance->Font For...
;; and then setting "Adopt Face and Frame Parameter as Frame Default"
(if window-system
    (load-theme 'deeper-blue t)
  (load-theme 'wheatgrass t))

;; Set the background color for the header.
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(company-preview ((t (:background "#073642" :foreground "#2aa198"))))
 '(company-preview-common ((t (:foreground "#93a1a1" :underline t))))
 '(company-scrollbar-bg ((t (:background "#073642" :foreground "#2aa198"))))
 '(company-scrollbar-fg ((t (:foreground "#002b36" :background "#839496"))))
 '(company-template-field ((t (:background "#7B6000" :foreground "#073642"))))
 '(company-tooltip ((t (:background "black" :foreground "DeepSkyBlue1"))))
 '(company-tooltip-annotation ((t (:foreground "#93a1a1" :background "#073642"))))
 '(company-tooltip-common ((t (:foreground "#93a1a1" :underline t))))
 '(company-tooltip-common-selection ((t (:foreground "#93a1a1" :underline t))))
 '(company-tooltip-mouse ((t (:background "DodgerBlue4" :foreground "CadetBlue1"))))
 '(company-tooltip-selection ((t (:background "DodgerBlue4" :foreground "CadetBlue1"))))
 '(header-line ((t (:background "#003366"))))
 '(which-func ((t (:foreground "blue")))))

;; company-mode colors. These are borrowed from Solarized and tweaked to look better
;; with deeper-blue. Could use improvement but I have no time.


;; I don't care to see the splash screen
(setq inhibit-splash-screen t)

;; (when (display-graphic-p)
;;   ;; Hide the scroll bar
;;   (scroll-bar-mode -1)
;;   (defvar my-font-size 90)
;;   ;; Make mode bar small
;;   (set-face-attribute 'mode-line nil  :height my-font-size)
;;   ;; Set the header bar font
;;   (set-face-attribute 'header-line nil  :height my-font-size)
;;   ;; Set default window size and position
;;   (setq default-frame-alist
;;         '((top . 0) (left . 0) ;; position
;;           (width . 110) (height . 90) ;; size
;;           ))
;;   ;; Enable line numbers on the LHS
;;   (global-linum-mode 1)
;;   ;; Set the font to size 9 (90/10).
;;   (set-face-attribute 'default nil :height my-font-size)
;;   )
;; 
;; (setq-default indicate-empty-lines t)
;; (when (not indicate-empty-lines)
;;   (toggle-indicate-empty-lines))
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Enable which function mode and set the header line to display both the
;; path and the function we're in
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(which-function-mode t)

;; Remove function from mode bar
(setq mode-line-misc-info
      (delete (assoc 'which-func-mode
                     mode-line-misc-info) mode-line-misc-info))


(defmacro with-face
    (str &rest properties)
  `(propertize ,str 'face (list ,@properties)))

(defun sl/make-header ()
  "."
  (let* ((sl/full-header (abbreviate-file-name buffer-file-name))
         (sl/header (file-name-directory sl/full-header))
         (sl/drop-str "[...]")
         )
    (if (> (length sl/full-header)
           (window-body-width))
        (if (> (length sl/header)
               (window-body-width))
            (progn
              (concat (with-face sl/drop-str
                                 :background "blue"
                                 :weight 'bold
                                 )
                      (with-face (substring sl/header
                                            (+ (- (length sl/header)
                                                  (window-body-width))
                                               (length sl/drop-str))
                                            (length sl/header))
                                 ;; :background "red"
                                 :weight 'bold
                                 )))
          (concat 
           (with-face sl/header
                      ;; :background "red"
                      :foreground "red"
                      :weight 'bold)))
      (concat (if window-system ;; In the terminal the green is hard to read
                  (with-face sl/header
                         ;; :background "green"
                         ;; :foreground "black"
                         :weight 'bold
                         :foreground "#8fb28f"
                         )
                (with-face sl/header
                         ;; :background "green"
                         ;; :foreground "black"
                         :weight 'bold
                         :foreground "blue"
                         ))
              (with-face (file-name-nondirectory buffer-file-name)
                         :weight 'bold
                         ;; :background "red"
                         )))))

(defun sl/display-header ()
  "Create the header string and display it."
  ;; The dark blue in the header for which-func is terrible to read.
  ;; However, in the terminal it's quite nice
  (if window-system
      (custom-set-faces
       '(which-func ((t (:foreground "#8fb28f")))))
    (custom-set-faces
       '(which-func ((t (:foreground "blue"))))))
  ;; Set the header line
  (setq header-line-format
        
        (list "-"
              '(which-func-mode ("" which-func-format))
              '("" ;; invocation-name
                (:eval (if (buffer-file-name)
                           (concat "[" (sl/make-header) "]")
                         "[%b]")))
              )
        )
  )
;; Call the header line update
(add-hook 'buffer-list-update-hook
          'sl/display-header)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package: yasnippet
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'yasnippet)
;; To get a bunch of extra snippets that come in super handy see:
;; https://github.com/AndreaCrotti/yasnippet-snippets
;; or use:
;; git clone https://github.com/AndreaCrotti/yasnippet-snippets.git ~/.emacs.d/yassnippet-snippets/
(add-to-list 'yas-snippet-dirs "~/.emacs.d/yasnippet-snippets/")
(yas-global-mode 1)
(yas-reload-all)

(provide '.emacs)
;;; .emacs ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["#eee8d5" "#dc322f" "#859900" "#b58900" "#268bd2" "#d33682" "#2aa198" "#839496"])
 '(compilation-message-face (quote default))
 '(cua-global-mark-cursor-color "#2aa198")
 '(cua-normal-cursor-color "#657b83")
 '(cua-overwrite-cursor-color "#b58900")
 '(cua-read-only-cursor-color "#859900")
 '(custom-safe-themes
   (quote
    ("36ca8f60565af20ef4f30783aa16a26d96c02df7b4e54e9900a5138fb33808da" "da538070dddb68d64ef6743271a26efd47fbc17b52cc6526d932b9793f92b718" "0cd56f8cd78d12fc6ead32915e1c4963ba2039890700458c13e12038ec40f6f5" "b9e9ba5aeedcc5ba8be99f1cc9301f6679912910ff92fdf7980929c2fc83ab4d" "c74e83f8aa4c78a121b52146eadb792c9facc5b1f02c917e3dbb454fca931223" "8db4b03b9ae654d4a57804286eb3e332725c84d7cdab38463cb6b97d5762ad26" "a94f1a015878c5f00afab321e4fef124b2fc3b823c8ddd89d360d710fc2bddfc" "af717ca36fe8b44909c984669ee0de8dd8c43df656be67a50a1cf89ee41bde9a" "158013ec40a6e2844dbda340dbabda6e179a53e0aea04a4d383d69c329fba6e6" "2b8dff32b9018d88e24044eb60d8f3829bd6bbeab754e70799b78593af1c3aba" "c9ddf33b383e74dac7690255dd2c3dfa1961a8e8a1d20e401c6572febef61045" "a0feb1322de9e26a4d209d1cfa236deaf64662bb604fa513cca6a057ddf0ef64" "d8dc153c58354d612b2576fea87fe676a3a5d43bcc71170c62ddde4a1ad9e1fb" "3c83b3676d796422704082049fc38b6966bcad960f896669dfc21a7a37a748fa" "3eb93cd9a0da0f3e86b5d932ac0e3b5f0f50de7a0b805d4eb1f67782e9eb67a4" "251348dcb797a6ea63bbfe3be4951728e085ac08eee83def071e4d2e3211acc3" "d677ef584c6dfc0697901a44b885cc18e206f05114c8a3b7fde674fce6180879" "8aebf25556399b58091e533e455dd50a6a9cba958cc4ebb0aab175863c25b9a4" "a8245b7cc985a0610d71f9852e9f2767ad1b852c2bdea6f4aadc12cce9c4d6d0" "84d2f9eeb3f82d619ca4bfffe5f157282f4779732f48a5ac1484d94d5ff5b279" "b181ea0cc32303da7f9227361bb051bbb6c3105bb4f386ca22a06db319b08882" "003a9aa9e4acb50001a006cfde61a6c3012d373c4763b48ceb9d523ceba66829" "c79c2eadd3721e92e42d2fefc756eef8c7d248f9edefd57c4887fbf68f0a17af" default)))
 '(fci-rule-color "#eee8d5")
 '(highlight-changes-colors (quote ("#d33682" "#6c71c4")))
 '(highlight-symbol-colors
   (--map
    (solarized-color-blend it "#fdf6e3" 0.25)
    (quote
     ("#b58900" "#2aa198" "#dc322f" "#6c71c4" "#859900" "#cb4b16" "#268bd2"))))
 '(highlight-symbol-foreground-color "#586e75")
 '(highlight-tail-colors
   (quote
    (("#eee8d5" . 0)
     ("#B4C342" . 20)
     ("#69CABF" . 30)
     ("#69B7F0" . 50)
     ("#DEB542" . 60)
     ("#F2804F" . 70)
     ("#F771AC" . 85)
     ("#eee8d5" . 100))))
 '(hl-bg-colors
   (quote
    ("#DEB542" "#F2804F" "#FF6E64" "#F771AC" "#9EA0E5" "#69B7F0" "#69CABF" "#B4C342")))
 '(hl-fg-colors
   (quote
    ("#fdf6e3" "#fdf6e3" "#fdf6e3" "#fdf6e3" "#fdf6e3" "#fdf6e3" "#fdf6e3" "#fdf6e3")))
 '(hl-paren-colors (quote ("#2aa198" "#b58900" "#268bd2" "#6c71c4" "#859900")))
 '(magit-diff-use-overlays nil)
 '(nrepl-message-colors
   (quote
    ("#dc322f" "#cb4b16" "#b58900" "#546E00" "#B4C342" "#00629D" "#2aa198" "#d33682" "#6c71c4")))
 '(package-selected-packages
   (quote
    (scala-mode abyss-theme alect-themes ample-theme ample-zen-theme writegood-mode window-numbering web-mode vlf solarized-theme zygospore yasnippet-classic-snippets ws-butler with-editor which-key volatile-highlights use-package undo-tree srefactor spaceline-all-the-icons smart-mode-line-powerline-theme projectile-git-autofetch multiple-cursors markdown-mode+ magit-popup irony-eldoc iedit hungry-delete helm-swoop helm-rtags helm-projectile helm-ls-hg helm-ls-git helm-gtags helm-flyspell helm-flycheck helm-ctest google-c-style flyspell-popup flyspell-lazy flyspell-correct-popup flyspell-correct-ivy flyspell-correct-helm flymake-shell flymake-cppcheck flycheck-tip flycheck-rtags flycheck-pyflakes flycheck-pycheckers flycheck-popup-tip flycheck-irony eldoc-eval dtrt-indent company-rtags company-irony-c-headers company-irony company-c-headers comment-dwim-2 cmake-project cmake-mode cmake-ide clean-aindent-mode clang-format cl-print cl-generic autopair auto-complete auctex anzu airline-themes)))
 '(pos-tip-background-color "#eee8d5")
 '(pos-tip-foreground-color "#586e75")
 '(safe-local-variable-values (quote ((/usr/lib64/clang/6\.0\.1/include/))))
 '(smartrep-mode-line-active-bg (solarized-color-blend "#859900" "#eee8d5" 0.2))
 '(sml/pre-modes-separator (propertize " " (quote face) (quote sml/modes)))
 '(term-default-bg-color "#fdf6e3")
 '(term-default-fg-color "#657b83")
 '(vc-annotate-background nil)
 '(vc-annotate-background-mode nil)
 '(vc-annotate-color-map
   (quote
    ((20 . "#dc322f")
     (40 . "#c3c373730000")
     (60 . "#b9b97d7d0000")
     (80 . "#b58900")
     (100 . "#a24c87870000")
     (120 . "#9b9b87870000")
     (140 . "#94e987870000")
     (160 . "#8e3887870000")
     (180 . "#859900")
     (200 . "#5a5a94e92d2c")
     (220 . "#43c39b9b43c3")
     (240 . "#2d2da24c5a59")
     (260 . "#1696a8fd70f0")
     (280 . "#2aa198")
     (300 . "#00009f9fa7a7")
     (320 . "#00009797b7b7")
     (340 . "#00008f8fc7c7")
     (360 . "#268bd2"))))
 '(vc-annotate-very-old-color nil)
 '(weechat-color-list
   (quote
    (unspecified "#fdf6e3" "#eee8d5" "#990A1B" "#dc322f" "#546E00" "#859900" "#7B6000" "#b58900" "#00629D" "#268bd2" "#93115C" "#d33682" "#00736F" "#2aa198" "#657b83" "#839496")))
 '(xterm-color-names
   ["#eee8d5" "#dc322f" "#859900" "#b58900" "#268bd2" "#d33682" "#2aa198" "#073642"])
 '(xterm-color-names-bright
   ["#fdf6e3" "#cb4b16" "#93a1a1" "#839496" "#657b83" "#6c71c4" "#586e75" "#002b36"]))

;; define function that move-line-up
(defun move-line-up ()
  "Move up the current line."
  (interactive)
  (transpose-lines 1)
  (forward-line -2)
  (indent-according-to-mode))

;; define function that move-line-down
(defun move-line-down ()
  "Move down the current line."
  (interactive)
  (forward-line 1)
  (transpose-lines 1)
  (forward-line -1)
  (indent-according-to-mode))

;; set global key bindings for move-line up & down functions
(global-set-key [(control shift up)]  'move-line-up)
(global-set-key [(control shift down)]  'move-line-down)

;; set global key bindings for comment line
(global-set-key (kbd "C-x /") 'comment-line)

;; initialize solarized theme and set as default
(require 'color-theme)
(require 'color-theme-solarized)
(load-theme 'solarized t)

;; powerline package for mode-line
(setq sml/theme 'dark)
(smart-mode-line-enable 1)

;; display line numbers initally
(display-line-numbers-mode 1)

;; show battery status
(display-battery-mode 1)

;; Modeline settings
;; Show 24-hour time and date on status bar
(setq display-time-24hr-format t)
(setq display-time-day-and-date t)
(display-time)

;; change the comment style for c-mode
(add-hook 'c-mode-hook (lambda () (setq comment-start "//"
                                       comment-end   "")))

;; set global key bind for jump to other file from a source file
(global-set-key (kbd "C-x C-h") 'ff-find-other-file)

;; set global default modes
(add-hook 'after-init-hook 'global-display-line-numbers-mode)

;; display line numbers initally
(display-line-numbers-mode 1)

;; ********************************************************
;; global gtags settings 
(autoload 'gtags-mode "gtags" "" t)
;; (add-hook 'gtags-mode-hook
;;   '(lambda ()
;;         ; Local customization (overwrite key mapping)
;;         (define-key gtags-mode-map "\C-f" 'scroll-up)
;;         (define-key gtags-mode-map "\C-b" 'scroll-down)
;; ))
(add-hook 'gtags-select-mode-hook
  '(lambda ()
        (setq hl-line-face 'underline)
        (hl-line-mode 1)
))
(add-hook 'c-mode-hook
  '(lambda ()
        (gtags-mode 1)))
; Customization
(setq gtags-suggested-key-mapping t)
(setq gtags-auto-update t)
;; ********************************************************


;; use builtin backup file system
(setq
 backup-by-copying t        ; don't clobber symlinks
 backup-directory-alist
 '(("." . "~/.emacs.d/backups/"))     ; don't litter my fs tree
 delete-old-versions t
 kept-new-versions 6
 kept-old-versions 2
 version-control t)         ; use versioned backups
;; ********************************************************

;; block transpose lines up and down
(defun move-line-up ()
  "Move up the current line."
  (interactive)
  (transpose-lines 1)
  (forward-line -2)
  (indent-according-to-mode))

(defun move-line-down ()
  "Move down the current line."
  (interactive)
  (forward-line 1)
  (transpose-lines 1)
  (forward-line -1)
  (indent-according-to-mode))

(global-set-key [(meta shift up)]  'move-line-up)
(global-set-key [(meta shift down)]  'move-line-down)
;; ********************************************************

(provide 'init.el)
;;; init.el ends here
