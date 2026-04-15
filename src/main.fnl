;; title:  Dodge
;; author: QBitStudio
;; desc:   A dodge game designed by QBitSoft.
;; script: fennel
;; Acun code ici présent n'a été généré par un LLM.
;; #NoAi

(global state 0) ;; 0: start, 1: playing, 2: game over.
(global best-score 0)
(global player-x 120)
(global player-y 68)
(global player-sprite 1)
(global axis-x 0)
(global axis-y 0)

(global is-initializing-game false)

(global chad-mult 1)

;; Flies
(global flies []) ;; {fly-pos-x, fly-pos-y, fly-vector-x, fly-vector-y, fly-respawn-delay}

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
  (set state new-state)
  (set is-initializing-game true))

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

(fn trace-flies []
  (each [key value (ipairs flies)]
    (trace "{")
    (trace (.. "pos-x: " (. value :fly-pos-x)))
    (trace (.. "pos-y: " (. value :fly-pos-y)))
    (trace (.. "vector-x: " (. value :fly-vector-x)))
    (trace (.. "vector-y: " (. value :fly-vector-y)))
    (trace (.. "respawn-delay: " (. value :fly-respawn-delay)))
    (trace "}")))

(fn new-fly [pos-x pos-y dir-start-x dir-start-y dir-end-x dir-end-y delay velocity]
  ;; ->AB=((xb-xa)*->i)+((yb-ya)*->i)
  (local vector-x (- dir-end-x dir-start-x))
  (local vector-y (- dir-end-y dir-start-y))
  (set velo (* velocity chad-mult))
  (table.insert flies {:fly-pos-x pos-x :fly-pos-y pos-y :fly-vector-x (* velo vector-x) :fly-vector-y (* velo vector-y) :fly-respawn-delay delay}))

(fn move-flies []
  ; (trace "Tdmsldvs")
  (each [key value (pairs flies)]
    (trace "Test")
    (tset value :fly-pos-x (+ (. value :fly-vector-x) (. value :fly-pos-x)))
    (tset value :fly-pos-y (+ (. value :fly-vector-y) (. value :fly-pos-y)))
    (trace (.. "Fly moved: {" (. value :fly-pos-x)))))

(fn render-flies []
  (each [key value (pairs flies)]
    (spr 16 (. value :fly-pos-x) (. value :fly-pos-y))))

(fn manage-flies []
  (if (= true is-initializing-game)
    (for [i 0 5 1]
      (trace "Generate fly.")
      (local start-x (math.random 240 480))
      (local start-y (math.random 136 272))
      (new-fly start-x start-y start-x start-y (math.random 0 240) (math.random 0 136) (* 120 (- 1 (- chad-mult 1))) (* chad-mult 10))
      (trace i)))
  (set is-initializing-game false)
  (trace-flies)
  (move-flies)
  (render-flies))

(fn render-game []
  (cls background-color-game)
  (map)
  (print (.. "Score: " score) 2 2 couleur-texte true 1 true)
  (manage-player-movements)
  (manage-flies))

(fn manage-main-game []
  (render-game))

;; Boucle principale exécutée à 60 FPS
(fn _G.TIC []
  ; (trace (.. "State " state)) ;; Debug

  (if (= state 0)
    (manage-start-menu)
    )
  
  (if (= state 1)
    (manage-main-game))
  
  ;; 4. Fait avancer le temps
  (set t (+ t 0.1)))