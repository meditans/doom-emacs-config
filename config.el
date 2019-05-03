;;; ~/.config/doom/config.el -*- lexical-binding: t; -*-

(require 'dash)

;; System clipboard
(setq x-select-enable-clipboard t)

;; Font to the right size
(setq doom-font (font-spec :family "hasklig" :size 21))

;; This is to guarantee that dante reads the configuration variables.
(defun doom|hack-local-variables () (hack-local-variables 'no-mode))
(add-hook 'change-major-mode-after-body-hook #'doom|hack-local-variables 'append)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; C-l for jumping parentheses
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(map! :i "C-l" 'sp-up-sexp)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Emacs pretty symbols, after https://github.com/i-tu/Hasklig/issues/84
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun my-correct-symbol-bounds (pretty-alist)
     (mapcar (lambda (el)
               (setcdr el (string ?\t (cdr el)))
               el)
             pretty-alist))

(defun my-ligature-list (ligatures codepoint-start)
     "Create an alist of strings to replace with
codepoints starting from codepoint-start."
     (let ((codepoints (-iterate '1+ codepoint-start (length ligatures))))
       (-zip-pair ligatures codepoints)))

; list can be found at https://github.com/i-tu/Hasklig/blob/master/GlyphOrderAndAliasDB#L1588
(setq my-hasklig-ligatures
      (let* ((ligs '("&&" "***" "*>" "\\\\" "||" "|>" "::"
                     "==" "===" "==>" "=>" "=<<" "!!" ">>"
                     ">>=" ">>>" ">>-" ">-" "->" "-<" "-<<"
                     "<*" "<*>" "<|" "<|>" "<$>" "<>" "<-"
                     "<<" "<<<" "<+>" ".." "..." "++" "+++"
                     "/=" ":::" ">=>" "->>" "<=>" "<=<" "<->")))
        (my-correct-symbol-bounds (my-ligature-list ligs #Xe100))))

;; And now for the invocation (important to do it this way for the ui component
;; of doom)
(after! haskell-mode
  (set-pretty-symbols! 'haskell-mode :alist my-hasklig-ligatures))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; med/hp facility for compactly declaring nix haskell dependencies
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Creating a new variable
(defvar med/hp nil)

;; Creating a function to transform med/hp in the correct dante invocation
(defun med/hp (l)
  (interactive)
  (let ((packages (s-join " " (--map (concat "(pkgs.haskell.lib.dontCheck (pkgs.haskell.lib.dontHaddock p." (symbol-name it) "))") l))))
    (setq-local dante-repl-command-line `("nix-shell" "-p"
                                          ,(concat "with import <nixpkgs> {}; pkgs.haskellPackages.ghcWithPackages (p: [" packages "])")
                                          "--run" "ghci"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Modify this or evaluate the expr to customize outline
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq-hook! 'haskell-mode-hook outline-regexp "-- \\*")
(add-hook 'haskell-mode-hook #'outline-minor-mode)
