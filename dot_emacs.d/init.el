;; -*- lexical-binding: t -*-
;;; This init file only loads config.el in its parent directory
;;; or the EMACS_CONFIG file from environmena variable.

;;* Base directory
(defconst my/home
  (expand-file-name "~/"))

(defconst my/emacs-d
  ;; customized emacd directory,
  ;; using this instead of user-emacs-directory makes serveral separate configs possible.
  (let ((parent (file-name-directory
                 (file-chase-links load-file-name))))
    (if (string= parent my/home)
        (expand-file-name "~/.emacs.d/")
      parent)))

;; (setq debug-on-error t)

(set-face-attribute 'default nil :foreground "white" :background "black")

;; Config locations
(defvar my/config-location (let ((config (getenv "EMACS_CONFIG")))
                             (if config
                                 (progn
                                   (message "Loading config %s" config)
                                   config
                                   )
                               (expand-file-name "config.el" my/emacs-d))))

(defvar my/config-compiled-location (concat my/config-location "c"))

(defun my/is-file-more-up-to-date (file1 file2)
  (interactive)
  (time-less-p (nth 5 (file-attributes file2)) (nth 5 (file-attributes file1))))

(defun my/load-compiled-or-compile ()
  (if (and (file-exists-p my/config-compiled-location) (my/is-file-more-up-to-date my/config-compiled-location my/config-location))
      (progn
        (message "Loading compiled config")
        (load-file my/config-compiled-location))
    (load-file my/config-location)))

;; This doesn't work with straight.el, no idea why
;;(defun my/compile-and-load-config ()
;;  (message "Compiling and loading config")
;;  (setq byte-compile-warnings '(not
;;				nresolved
;;				free-vars
;;				unresolved
;;				callargs
;;				redefine
;;				noruntime
;;				cl-functions
;;				interactive-only))
;;
;;  (byte-compile-file my/config-location t))

(my/load-compiled-or-compile)

;; Local Variables:
;; coding: utf-8
;; no-byte-compile: t
;; End:
(put 'set-goal-column 'disabled nil)
