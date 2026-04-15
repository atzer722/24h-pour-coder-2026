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

(global nutr-x 6)
(global nutr-y 0)
(global nutr-index 0)
(global nutr-temps 120)
(global nutr-delai nutr-temps)
(global nutr-affiche 0)

(var couleur-texte 12)  ; 6 = vert. Essaie 11 (bleu clair)
(var background-color-menu 0)  ; 12 = Blanc. Essaie 0 (Noir)
(var background-color-game 6)

(global map-sol [])
(for [i 1 17]
  (local map-x []) ;; new table each time
  (for [j 1 18]
    (tset map-x j (math.random 100)))
  (tset map-sol i map-x))

;; Variable pour l'animation
(var t 0)

(fn switch-state [btn next-state]
  (if (= true btn)
    (set state next-state)))

(fn render-start-menu []
  (cls background-color-menu)

  (var decalage-y (* (math.sin t) 2))
  
  ;; Start menu title and sub.
  (for [i 0 29]
    (for [j 0 29]
      (spr 7 (* i 8) (* j 8) 0)))

  (print (.. "Best Score: " 0) 2 2 couleur-texte true 1 true)

  (print "Dodge!" 100 (+ 50 decalage-y) couleur-texte)
  (print "Press space to start" 80 (+ 80 decalage-y) couleur-texte false 1 true)

  (print "By QbitSoft" 197 128 couleur-texte true 1 true)

  (spr 1 7 35 0 8)
  (spr 33 165 35 0 8))

(fn change-state [sfx-id sfx-note new-state]
  (sfx sfx-id sfx-note -1)
  (set state new-state)
  (set is-initializing-game true))

(fn manage-start-menu [] ;; State 0. Start menu.
  (render-start-menu)

  ;; QUAND bouton flèche haut préssée Jouer un son et passe en mode jeu si on est dans le start menu
  (if (= true (key 48))
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
  (spr 5 (- player-x 4) (- player-y 4) 0)
  (spr 6 (+ player-x 4) (- player-y 4) 0)
  (spr 21 (- player-x 4) (+ player-y 4) 0)
  (spr 22 (+ player-x 4) (+ player-y 4) 0)
  (spr player-sprite player-x player-y 0)
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

  (for [i 1 (length map-sol)]
    (local inner (. map-sol i))
    (for [j 1 (length inner)]
      (if (< (. inner j) 41) ;; Vide : 40 %
        (spr 48 (* (+ j 5) 8) (* (- i 1) 8) 0)
        (< (. inner j) 61) ;; Fleurs : 20 %
        (spr ( + 64 (% t 4)) (* (+ j 5) 8) (* (- i 1) 8) 0)
        (< (. inner j) 81) ;; Herbe : 20 %
        (spr ( + 80 (% t 6)) (* (+ j 5) 8) (* (- i 1) 8) 0)
        (< (. inner j) 86) ;; Flaque : 5 %
        (spr ( + 96 (% t 6)) (* (+ j 5) 8) (* (- i 1) 8) 0)
        (< (. inner j) 100) ;; Cailloux : 14 %
        (spr 112 (* (+ j 5) 8) (* (- i 1) 8) 0)
        (spr 113 (* (+ j 5) 8) (* (- i 1) 8) 0)))) ;; Fenouil : 1% --> A DESSINER !!!

  (print (.. "Score: " score) 2 2 couleur-texte true 1 true))

(fn generate-nutriment []
  (if (> nutr-temps 30)
    (set nutr-temps (- nutr-temps 2)))
  (set nutr-delai nutr-temps)

  (set nutr-x (* (+ (math.random 16) 6) 8))
  (set nutr-y (* (math.random 15) 8))

  (local rand (math.random 5))
  (if (= rand 5)
    (set nutr-index 33)
    (set nutr-index 32))

  (set nutr-affiche 1))

(fn render-nutriment []
  (var decalage-x (* (math.cos t) 1))
  (var decalage-y (* (math.sin t) 2))
  (spr 34 (+ nutr-x decalage-x) (+ (+ nutr-y 0 decalage-y) 4) 0)
  (spr nutr-index (+ nutr-x decalage-x) (+ nutr-y 0 decalage-y) 0))

(fn manage-ingere-nutriment []
  (set nutr-x -1)
  (set nutr-y -1)

  (set nutr-affiche 0)

  (if (= nutr-index 32)
    (set score (+ score 100))
    (set score (+ score 500)))
  
  (if (= nutr-index 32)
    (sfx 1 c6 -1)
    (sfx 2 c6 -1)))

(fn detect-collision [ax ay aw ah bx by bw bh]
  (and (and (< ax (+ bx bw)) (> (+ ax aw) bx)) (and (< ay (+ by bh)) (> (+ ay ah) by))))

(fn manage-main-game []
  (render-game)

  (if (= nutr-affiche 0)
    (if (> nutr-delai 0)
      (set nutr-delai (- nutr-delai 1))
      (generate-nutriment))
    (render-nutriment))
  
  (if (= true (detect-collision player-x player-y 8 8 nutr-x nutr-y 8 8))
    (manage-ingere-nutriment))
  
  (manage-player-movements))

(fn change-state [sfx-id sfx-note new-state]
  (sfx sfx-id sfx-note -1)
  (set state new-state))

(fn render-game-over []
  (cls background-color-menu)

  (var decalage-y (* (math.sin t) 2))
  
  ;; Start menu title and sub.
  (for [i 0 29]
    (for [j 0 29]
      (spr 7 (* i 8) (* j 8) 0)))

  (print (.. "Score: " score) 2 2 couleur-texte true 1 true)

  (print (.. "Best Score: " best-score) 2 22 couleur-texte true 1 true)

  (print "Press space to restart" 80 (+ 80 decalage-y) couleur-texte false 1 true)
  
  (spr 4 100 100 0 8))

(fn manage-game-over []
  (if (> score best-score)
    (set best-score score))
  render-game-over)

  (if (= true (key 48))
    (set state 0)
  )

;; Boucle principale exécutée à 60 FPS
(fn _G.TIC []
  ;;(trace (.. "State " state)) ;; Debug
  
  (if (= state 0)
    (manage-start-menu)
    )
  
  (if (= state 1)
    (manage-main-game))
  
  (if (= state 2)
    (manage-game-over))
  
  ;; 4. Fait avancer le temps
  (set t (+ t 0.1)))