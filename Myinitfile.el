;; Inicializar sistema de paquetes
(require 'package)

;; Agregar repositorios de paquetes
(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")))

;; Inicializar paquetes
(package-initialize)

;; Actualizar lista de paquetes si está vacía
(unless package-archive-contents
  (package-refresh-contents))

;; Instalar use-package si no está presente
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

;; Configurar use-package
(eval-when-compile
  (require 'use-package))
(setq use-package-always-ensure t)  ; Instalar automáticamente paquetes faltantes
(setq use-package-always-defer t)   ; Cargar paquetes solo cuando se necesitan

;; Renombrar buffer actual
(global-set-key (kbd "C-x :") 'rename-buffer)

;; Deshacer (C-z normal, no suspender)
(global-set-key (kbd "C-z") 'undo)

;; Modo línea en terminal
(global-set-key (kbd "C-c C-j") 'term-line-mode)

;; Intercambiar estado de ventanas
(global-set-key (kbd "C-c TAB") 'window-swap-states)

;; Moverse entre ventanas con flechas
(global-set-key (kbd "C-c <up>") 'windmove-up)
(global-set-key (kbd "C-c <down>") 'windmove-down)
(global-set-key (kbd "C-c <left>") 'windmove-left)
(global-set-key (kbd "C-c <right>") 'windmove-right)

;; Redimensionar ventanas
(global-set-key (kbd "S-M-<left>") 'shrink-window-horizontally)
(global-set-key (kbd "S-M-<right>") 'enlarge-window-horizontally)
(global-set-key (kbd "S-M-<down>") 'shrink-window)
(global-set-key (kbd "S-M-<up>") 'enlarge-window)

;; Cerrar buffer y ventana simultáneamente
(defun delete-window-kill ()
  "Mata el buffer actual y elimina la ventana."
  (interactive)
  (call-interactively 'kill-buffer)
  (call-interactively 'delete-window))
(global-set-key (kbd "C-x M-k") 'delete-window-kill)

;; Maximizar ventana actual
(global-set-key (kbd "C-x -") 'maximize-window)

;; Compilar proyecto
(global-set-key (kbd "C-M-x") 'compile)

;; Ejecutar comando en eshell
(global-set-key (kbd "M-°") 'eshell-command)

(use-package helm
  :ensure t
  :bind (("C-x b" . helm-buffers-list)      ; Lista de buffers
         ("M-x" . helm-M-x)                 ; Ejecutar comandos
         ("C-x C-f" . helm-find-files)      ; Buscar archivos
         ("C-s" . helm-occur)              ; Buscar en buffer
         ("M-y" . helm-show-kill-ring)     ; Historial de kill-ring
         ("C-c h g" . helm-google-suggest)) ; Sugerencias de Google
  :config
  (helm-mode 1))

(use-package helm-swoop
  :ensure t
  :bind (("M-i" . helm-swoop)                      ; Búsqueda rápida
         ("M-I" . helm-swoop-back-to-last-point)   ; Volver al punto anterior
         ("C-c M-i" . helm-multi-swoop)            ; Búsqueda en múltiples buffers
         ("C-x M-i" . helm-multi-swoop-all))       ; Búsqueda en todos los buffers
  :config
  ;; Integración con isearch
  (define-key isearch-mode-map (kbd "M-i") 'helm-swoop-from-isearch)
  (define-key helm-swoop-map (kbd "M-i") 'helm-multi-swoop-all-from-helm-swoop))

;; Fuente por defecto
(add-to-list 'default-frame-alist
             '(font . "Monospace-10.5:bold"))

(use-package doom-modeline
  :ensure t
  :hook (after-init . doom-modeline-mode)
  :custom
  (doom-modeline-height 2)
  (doom-modeline-bar-width 10))

(use-package all-the-icons
  :ensure t
  :if (display-graphic-p))

;; Transparencia (solo en modo gráfico)
(when (display-graphic-p)
  (set-frame-parameter (selected-frame) 'alpha '(92 . 90))
  (add-to-list 'default-frame-alist '(alpha 92 . 90)))

;; Números de línea modernos (reemplaza linum-mode)
(use-package display-line-numbers
  :hook (prog-mode . display-line-numbers-mode)
  :custom
  (display-line-numbers-type 'relative))

(use-package multi-term
  :ensure t
  :custom
  (multi-term-program "/bin/zsh")
  :hook (emacs-startup . multi-term)
  :bind (("C-x \"" . my-multi-term-keys-below)  ; Terminal abajo
         ("C-x #" . my-multi-term-keys-right))  ; Terminal a la derecha
  :config
  ;; Funciones auxiliares para abrir terminales
  (defun my-multi-term-keys-below ()
    "Divide la ventana abajo y abre un terminal."
    (interactive)
    (call-interactively 'split-window-below)
    (call-interactively 'other-window)
    (call-interactively 'multi-term))

  (defun my-multi-term-keys-right ()
    "Divide la ventana a la derecha y abre un terminal."
    (interactive)
    (call-interactively 'split-window-right)
    (call-interactively 'other-window)
    (call-interactively 'multi-term))

  ;; Teclas especiales en modo terminal
  (defcustom term-unbind-key-list
    '("C-z" "C-x" "C-c" "C-h" "C-y" "<ESC>")
    "Teclas que se desactivan en modo terminal."
    :type 'list
    :group 'multi-term)

  (defcustom term-bind-key-alist
    '(("C-c C-c" . term-interrupt-subjob)
      ("C-p" . previous-line)
      ("C-n" . next-line)
      ("C-s" . isearch-forward)
      ("C-r" . isearch-backward)
      ("C-m" . term-send-raw)
      ("M-f" . term-send-forward-word)
      ("M-b" . term-send-backward-word)
      ("M-o" . term-send-backspace)
      ("M-p" . term-send-up)
      ("M-n" . term-send-down)
      ("M-r" . term-send-reverse-search-history)
      ("M-," . term-send-input)
      ("M-." . comint-dynamic-complete))
    "Mapeo de teclas para modo terminal."
    :type 'alist
    :group 'multi-term))

(use-package expand-region
  :ensure t
  :bind ("C-=" . er/expand-region))

(use-package projectile
  :ensure t
  :bind-keymap ("C-c p" . projectile-command-map)
  :custom
  (projectile-completion-system 'helm)
  (projectile-project-search-path '("~/Documentos/"))  ; Ajusta esta ruta
  :config
  (projectile-mode +1))

(use-package company
  :ensure t
  :hook (after-init . global-company-mode)
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.1)
  (company-global-modes '(not mhtml-mode)))

(use-package yasnippet
  :ensure t
  :config
  (yas-global-mode 1)
  (setq yas-snippet-dirs '("~/.emacs.d/snippets")))

(use-package company-c-headers
  :ensure t
  :after company
  :config
  (add-to-list 'company-backends 'company-c-headers)
  (add-to-list 'company-c-headers-path-system "/usr/include/"))

(use-package flycheck
  :ensure t
  :hook (after-init . global-flycheck-mode)
  :config
  ;; Configuración para C/C++
  (add-hook 'c++-mode-hook
            (lambda () (setq flycheck-clang-include-path
                             (list (expand-file-name "/usr/include/"))))))

(use-package helm-gtags
  :ensure t
  :hook ((c-mode . helm-gtags-mode)
         (c++-mode . helm-gtags-mode)
         (asm-mode . helm-gtags-mode))
  :bind (:map helm-gtags-mode-map
              ("M-t" . helm-gtags-find-tag)
              ("M-r" . helm-gtags-find-rtag)
              ("M-s" . helm-gtags-find-symbol)
              ("M-g M-p" . helm-gtags-parse-file)
              ("C-c <" . helm-gtags-previous-history)
              ("C-c >" . helm-gtags-next-history)
              ("M-," . helm-gtags-pop-stack)))

(use-package iedit
  :ensure t
  :bind ("C-c ;" . iedit-mode))

(use-package highlight-indent-guides
  :ensure t
  :hook (prog-mode . highlight-indent-guides-mode)
  :custom
  (highlight-indent-guides-method 'bitmap)
  (highlight-indent-guides-responsive 'top))

(use-package emmet-mode
  :ensure t
  :hook ((sgml-mode . emmet-mode)
         (css-mode . emmet-mode)
         (web-mode . emmet-mode)))

(use-package simple-httpd
  :ensure t)

(use-package pdf-tools
  :ensure t
  :magic ("%PDF" . pdf-view-mode)
  :hook (pdf-view-mode . pdf-view-restore-mode)
  :config
  (pdf-tools-install :noquery))

;; Aplicaciones para abrir archivos externos
(setq org-file-apps
      '((auto-mode . emacs)
        ("\\.x?html?\\'" . "brave %s")
        ("\\.pdf\\'" . "evince \"%s\"")
        ("\\.djvu\\'" . "evince \"%s\"")
        ("\\.pdf::\\([0-9]+\\)\\'" . "evince \"%s\" -p %1")
        ("\\.xoj" . "xournal %s")))

(org-babel-do-load-languages
 'org-babel-load-languages
 '((C . t)
   (python . t)
   (gnuplot . t)
   (js . t)
   (shell . t)
   (emacs-lisp . t)
   (latex . t)))

(use-package slime
  :ensure t
  :custom
  (inferior-lisp-program "/bin/sbcl"))

(use-package org-bullets
  :ensure t
  :hook (org-mode . org-bullets-mode))

(setq org-todo-keywords
      '((sequence "TODO(t)" "INPROGRESS(i)" "FEEDBACK(f)" "VERIFY(v)" "|" "DONE(d)" "DELEGATED(D)" "CANCELLED(c)")))

(setq org-todo-keyword-faces
      '(("TODO" :background "red" :foreground "black" :box (:line-width 2 :style released-button))
        ("INPROGRESS" :background "#ff5a00" :foreground "black" :box (:line-width 2 :style released-button))
        ("FEEDBACK" :background "#ffd000" :foreground "black" :box (:line-width 2 :style released-button))
        ("VERIFY" :background "#ff00dd" :foreground "black" :box (:line-width 2 :style released-button))
        ("DONE" :background "green" :foreground "black" :box (:line-width 2 :style released-button))
        ("DELEGATED" :background "blue" :foreground "black" :box (:line-width 2 :style released-button))
        ("CANCELLED" :background "blue" :foreground "black" :box (:line-width 2 :style released-button))))

(setq org-log-done 'time)

;; Advertencias de compilación
(setq byte-compile-warnings '(not free-vars))

;; Pantalla completa con F11
(defun toggle-fullscreen (&optional f)
  "Alterna entre pantalla completa y ventana normal."
  (interactive)
  (let ((current-value (frame-parameter nil 'fullscreen)))
    (set-frame-parameter nil 'fullscreen
                         (if (equal 'fullboth current-value)
                             (if (boundp 'old-fullscreen) old-fullscreen nil)
                           (progn (setq old-fullscreen current-value)
                                  'fullboth)))))
(global-set-key [f11] 'toggle-fullscreen)

;; Ocultar mensaje de inicio
(setq inhibit-startup-message t)

;; Desactivar barra de herramientas
(tool-bar-mode -1)

;; Desactivar barra de menú
(menu-bar-mode -1)

;; Desactivar barra de desplazamiento
(scroll-bar-mode -1)

;; Resaltar línea actual
(global-hl-line-mode +1)

;; Eliminar texto al seleccionar
(delete-selection-mode +1)

;; Mostrar paréntesis coincidentes
(show-paren-mode +1)

;; Modo de línea visual
(global-visual-line-mode 1)

(use-package ispell
  :custom
  (ispell-program-name "aspell")
  :config
  ;; Omitir corrección en regiones específicas de Org
  (add-to-list 'ispell-skip-region-alist '(":\\(PROPERTIES\\|LOGBOOK\\):" . ":END:"))
  (add-to-list 'ispell-skip-region-alist '("#\\+BEGIN_SRC" . "#\\+END_SRC"))
  (add-to-list 'ispell-skip-region-alist '("#\\+TITLE:" . "#\\+AUTHOR:" . "#\\+DATE:")))

(use-package sr-speedbar
  :ensure t
  :bind ("M-1" . sr-speedbar-toggle))

(use-package atomic-chrome
  :ensure t
  :config
  (atomic-chrome-start-server)
  (setq atomic-chrome-url-major-mode-alist
        '(("github\\.com" . gfm-mode)
          ("redmine" . textile-mode)
          ("overleaf\\.com" . latex-mode))))

(use-package recentf
  :config
  (recentf-mode 1)
  (setq recentf-max-menu-items 25))

;; Ajustar recolección de basura para mejor rendimiento
(setq gc-cons-threshold 100000000)  ; 100MB
(setq read-process-output-max (* 1024 1024))  ; 1MB

(set-language-environment "UTF-8")
(set-default-coding-systems 'utf-8)

(message "Configuración cargada exitosamente en %s" (current-time-string))
