;;; auto-backup-after-save.el --- create backup automatically after save

;; Copyright (C)

;; Author: Akihiko Takahashi
;; Version: 1.0
;; Created: 2017-04-25
;; Keywords: backup

;;; Installation:

;; Place this file in your `load-path', and add
;; the following lines in your ~/.emacs.d/init.el files:
;; (require 'auto-backup-after-save)
;; (add-hook 'after-save-hook 'auto-backup-after-save)

;;; ChangeLog:
;; 1.0 ... initial version


;;; Code:
(defconst abas/version "1.0" "Version of this program.")
(defvar abas/backup-directory "~/.emacs.d/backups" "Backup directory.")
(defconst abas/time-format "%Y%m%d%H%M%S"
  "Format given `format-time-string' which is append to filename.")
(defvar abas/size-limit 500000
  "Maximum size of a file (in bytes) that copied after save.

If file size is greater than `abas/size-limit', don't create backup file.
If this variable is nil, all files are backuped after save.")
(defvar abas/ignore-regex "/backups?/"
  "Do not create backup file if file is matched by this regular expression.")
(defvar abas/directory-separator-regex "[/\\]"
  "Character which separate each directory.")
(defvar abas/directory-new-separator "!"
  "Character which separate each directory in backup.")

(defun auto-backup-after-save-version ()
  "Message version"
  (interactive)
  (message abas/version))

(defun auto-backup-after-save ()
  "Create backup file after save automatically.

File matched `abas/ignore-regex' or size greater than `abas/size-limit'
are not backuped"
  (when (not (file-exists-p abas/backup-directory))
    (make-directory abas/backup-directory t))
  (let ((bfn (buffer-file-name)))
    (when (and bfn
	       (not (string-match abas/ignore-regex bfn))
	       (or (not abas/size-limit)
		   (<= (buffer-size) abas/size-limit)))
      (copy-file bfn (auto-backup-after-save-location bfn) t t t))))

(defun auto-backup-after-save-location (filename)
  "Return backup file name with full path."
  (let* ((drive-convert-filename
	  (if (string-match "\\([^:]+\\):" filename)
	      (replace-match (format "%sdrive_%s"
				     abas/directory-new-separator
				     (match-string 1 filename))
			     nil nil filename)
	    filename))
	 (separator-changed-dir
	  (let ((tmp drive-convert-filename))
	    (while (string-match abas/directory-separator-regex tmp)
	      (setq tmp (replace-match abas/directory-new-separator nil nil tmp)))
	    tmp)))
    (format "%s/%s_%s"
	    (expand-file-name abas/backup-directory)
	    separator-changed-dir
	    (format-time-string abas/time-format))))

(provide 'auto-backup-after-save)

;;; auto-backup-after-save.el end here.
