;;; cl-print-autoloads.el --- automatically extracted autoloads
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "cl-print" "cl-print.el" (0 0 0 0))
;;; Generated autoloads from cl-print.el

(autoload 'cl-print-object "cl-print" "\
Dispatcher to print OBJECT on STREAM according to its type.
You can add methods to it to customize the output.
But if you just want to print something, don't call this directly:
call other entry points instead, such as `cl-prin1'.

\(fn OBJECT STREAM)" nil nil)

(autoload 'cl-prin1 "cl-print" "\


\(fn OBJECT &optional STREAM)" nil nil)

(autoload 'cl-prin1-to-string "cl-print" "\


\(fn OBJECT)" nil nil)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "cl-print" '("cl-print-")))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; cl-print-autoloads.el ends here
