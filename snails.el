;;; snails.el --- A modern, easy-to-expand fuzzy search framework

;; Filename: snails.el
;; Description: A modern, easy-to-expand fuzzy search framework
;; Author: Andy Stewart <lazycat.manatee@gmail.com>
;; Maintainer: Andy Stewart <lazycat.manatee@gmail.com>
;; Copyright (C) 2019, Andy Stewart, all rights reserved.
;; Created: 2019-05-16 21:26:09
;; Version: 0.1
;; Last-Updated: 2019-05-16 21:26:09
;;           By: Andy Stewart
;; URL: http://www.emacswiki.org/emacs/download/snails.el
;; Keywords:
;; Compatibility: GNU Emacs 26.1.92
;;
;; Features that might be required by this library:
;;
;;
;;

;;; This file is NOT part of GNU Emacs

;;; License
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.

;;; Commentary:
;;
;; A modern, easy-to-expand fuzzy search framework
;;

;;; Installation:
;;
;; Put snails.el to your load-path.
;; The load-path is usually ~/elisp/.
;; It's set in your ~/.emacs like this:
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;;
;; And the following to your ~/.emacs startup file.
;;
;; (require 'snails)
;;
;; No need more.

;;; Customize:
;;
;;
;;
;; All of the above can customize by:
;;      M-x customize-group RET snails RET
;;

;;; Change log:
;;
;; 2019/05/16
;;      * First released.
;;

;;; Acknowledgements:
;;
;;
;;

;;; TODO
;;
;;
;;

;;; Require

;;; Code:

(defvar snails-input-buffer " *snails input*")

(defvar snails-content-buffer " *snails content*")

(defvar snails-frame nil)

(defvar snails-parent-frame nil)

(defcustom snails-mode-hook '()
  "snails mode hook."
  :type 'hook
  :group 'snails)

(defvar snails-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-g") 'snails-quit)
    map)
  "Keymap used by `snails-mode'.")

(define-derived-mode snails-mode text-mode "snails"
  (interactive)
  (kill-all-local-variables)
  (setq major-mode 'snails-mode)
  (setq mode-name "snails")
  (use-local-map snails-mode-map)
  (run-hooks 'snails-mode-hook))

(defun snails ()
  (interactive)
  (snails-create-input-buffer)
  (snails-create-content-buffer)
  (snails-create-frame)
  )

(defun snails-create-input-buffer ()
  (with-current-buffer (get-buffer-create snails-input-buffer)
    (erase-buffer)
    (snails-mode)
    (buffer-face-set '(:background "#222" :foreground "gold" :height 180))
    (set-face-background 'hl-line "#222")
    (setq-local global-hl-line-overlay nil)
    (setq-local header-line-format nil)
    (setq-local mode-line-format nil)
    ))

(defun snails-create-content-buffer ()
  (with-current-buffer (get-buffer-create snails-content-buffer)
    (erase-buffer)
    (buffer-face-set '(:background "#111" :height 130))
    (setq-local header-line-format nil)
    (setq-local mode-line-format nil)
    (setq-local cursor-type nil)


    ))

(defun snails-monitor-input (begin end length)
  (when (string-equal (buffer-name) snails-input-buffer)
    (with-current-buffer snails-content-buffer
      (let* ((input (with-current-buffer snails-input-buffer
                      (buffer-substring (point-min) (point-max)))))
        (erase-buffer)

        (dolist (buf (buffer-list))
          (when (string-match-p (regexp-quote input) (buffer-name buf))
            (insert (format " %s\n" (buffer-name buf)))))

        (insert "\n")

        (dolist (file recentf-list)
          (when (string-match-p (regexp-quote input) file)
            (insert (format " %s\n" file))))
        )
      )))

(defun snails-create-frame ()
  (let* ((edges (frame-edges))
         (x (nth 0 edges))
         (y (nth 1 edges))
         (width (nth 2 edges))
         (height (nth 3 edges))
         (frame-width (truncate (* 0.4 width)))
         (frame-height (truncate (* 0.5 height)))
         (frame-x (/ (- width frame-width) 2))
         (frame-y (/ (- height frame-height) 4)))
    (setq snails-frame
          (make-frame
           '((minibuffer . nil)
             (visibility . nil)
             (internal-border-width . 0)
             )))

    (with-selected-frame snails-frame
      (set-frame-position snails-frame frame-x frame-y)
      (set-frame-size snails-frame frame-width frame-height t)
      (set-frame-parameter nil 'undecorated t)
      (split-window (selected-window) (nth 3 (window-edges (selected-window))) nil t)
      (switch-to-buffer snails-input-buffer)
      (other-window 1)
      (switch-to-buffer snails-content-buffer)
      (other-window 1)

      (add-hook 'after-change-functions
                'snails-monitor-input
                nil
                t)
      )

    (setq snails-parent-frame (selected-frame))
    (make-frame-visible snails-frame)))

(defun snails-quit ()
  (interactive)
  (delete-frame snails-frame))

(provide 'snails)

;;; snails.el ends here
