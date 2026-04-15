;; title:  Dodge
;; author: QBitStudio
;; desc:   A dodge game designed by QBitSoft.
;; script: fennel

(global state 0) ;; 0: start, 1: playing, 2: game over.
(global best-score 0)
(global player-x 120)
(global player-y 68)
(global player-sprite 1)
(global axis-x 0)
(global axis-y 0)

(global must-play-sfx false)

(global score 0)

(var couleur-texte 0)  ; 6 = vert. Essaie 11 (bleu clair)
(var background-color-menu 12)  ; 12 = Blanc. Essaie 0 (Noir)
(var background-color-game 6)



;; Variable pour l'animation
(var t 0)

(fn switch-state [btn next-state]
  (if (= true btn)
    (set state next-state)))

(fn render-start-menu []
  (cls background-color-menu)

  (var decalage-y (* (math.sin t) 5))
  
  ;; Start menu title and sub.
  (print (.. "Best Score: " 0) 2 2 couleur-texte true 1 true)

  (print "Dodge!" 45 (+ 50 decalage-y) couleur-texte)
  (print "press up arrow button to continue" 45 (+ 60 decalage-y) couleur-texte false 1 true)

  (print "By QBitSoft!" 200 130 couleur-texte true 1 true))



(fn change-state [sfx-id sfx-note new-state]
  (sfx sfx-id sfx-note -1)
  (set state new-state))


(fn manage-start-menu [] ;; State 0. Start menu.
  (render-start-menu)

  ;; QUAND bouton flèche haut préssée Jouer un son et passe en mode jeu si on est dans le start menu
  (if (= true (btnp 0))
    (change-state 0 c5 1)
  )
)

(fn manage-player-movements []
  (if (= true (btn 0))
    (set axis-y (- axis-y 1)))
  (if (= true (btn 1))
    (set axis-y (+ axis-y 1)))
  (if (= true (btn 2))
    (set axis-x (- axis-x 1)))
  (if (= true (btn 3))
    (set axis-x (+ axis-x 1)))
  (set player-y (+ player-y axis-y))
  (set player-x (+ player-x axis-x))
  (if (or (not= axis-y 0) (not= axis-x 0))
    (set player-sprite (+ 2 (% t 2)))
    (set player-sprite 1))
  (spr player-sprite player-x player-y)
  (set axis-x 0)
  (set axis-y 0))

(fn render-game []
  (cls background-color-game)
  (map)
  (print (.. "Score: " score) 2 2 couleur-texte true 1 true)
  (manage-player-movements))

(fn manage-main-game []
  (render-game))

;; Boucle principale exécutée à 60 FPS
(fn _G.TIC []
  (trace (.. "State " state)) ;; Debug
  
  (if (= state 0)
    (manage-start-menu)
    )
  
  (if (= state 1)
    (manage-main-game))
  
  ;; 4. Fait avancer le temps
  (set t (+ t 0.1)))