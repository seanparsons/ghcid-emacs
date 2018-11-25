;; Really basic ghcid support in emacs with compilation-mode
;; Use M-x ghcid to launch

(setq ghcid-height 15)
(setq ghcid-build-cmd "cabal new-repl all")
(setq ghcid-buf-name "*ghcid*")

(define-minor-mode ghcid-mode
  "A minor mode for ghcid terminals"
  :lighter " Ghcid"
  (compilation-minor-mode))

(defun new-ghcid-term ()
  (interactive)
  (kill-ghcid)
  (let ((ghcid-buf (get-buffer-create ghcid-buf-name)))
    (display-buffer
     ghcid-buf
     '((display-buffer-at-bottom
        display-buffer-pop-up-window
        display-buffer-reuse-window)
       (window-height . 18)))
    (select-window (get-buffer-window ghcid-buf))
    (make-term "ghcid" "/usr/bin/env" nil "bash")
    (term-mode)
    (term-char-mode)
    (term-set-escape-char ?\C-x)
    (setq-local term-buffer-maximum-size ghcid-height)
    (setq-local scroll-up-aggressively 1)
    (ghcid-mode)))

(defun kill-ghcid ()
  (let* ((ghcid-buf (get-buffer ghcid-buf-name))
         (ghcid-proc (get-buffer-process ghcid-buf)))
    (when (processp ghcid-proc)
      (progn
        (set-process-query-on-exit-flag ghcid-proc nil)
        (kill-process ghcid-proc)))))

(defun add-stars (s) (format "*%s*" s))

;; TODO Pass in compilation command like compilation-mode
(defun ghcid-command (h)
    (format "ghcid -c \"%s\" -h %s\n" ghcid-build-cmd h))

;; TODO Close stuff if it fails
(defun ghcid ()
  "Run ghcid"
  (interactive)
  (let ((cur (selected-window)))
    (new-ghcid-term)
    (comint-send-string ghcid-buf-name (ghcid-command ghcid-height))
    (select-window cur)))

;; Assumes that only one window is open
(defun ghcid-stop ()
  "Stop ghcid"
  (interactive)
  (let* ((ghcid-buf (get-buffer ghcid-buf-name))
         (ghcid-window (get-buffer-window ghcid-buf)))
    (when ghcid-buf
      (progn
        (kill-ghcid)
        (select-window ghcid-window)
        (kill-buffer-and-window)))))

(provide 'ghcid)
