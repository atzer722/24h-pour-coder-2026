;; title: Dodge!
;; author: QbitStudio
;; desc: A video game designed by QbitSoft
;; script: fennel

(global state 0) ; 0: start, 1: playing, 2: game over.
(global best-score 0)
(global player-x (- 120 4))
(global player-y (- 68 4))
(global player-sprite 1)
(global axis-x 0)
(global axis-y 0)
(global correct false)
(global music-state -1)
(global music-start-time 0)
(global game-start-time 0)
(global music-main 2)

(global is-initializing-game false)

(global chad-mult 1)
(global chad-mod-lvl 1.3)
(global chad-fly-spawned false)

; Flies
(global flies []) ; {fly-pos-x, fly-pos-y, fly-vector-x, fly-vector-y, fly-respawn-delay, is-chad}
; (global dead-flies-counter []) ; Counters of dead flies.

(global must-play-sfx false)

(global score 0)

(global nutr-x 6)
(global nutr-y 0)
(global nutr-index 0)
(global nutr-temps 120)
(global nutr-delai nutr-temps)
(global nutr-affiche 0)

(global GAME_MAX_X 192)
(global GAME_MIN_X 48)
(global GAME_MAX_Y 136)
(global GAME_MIN_Y 0)

(var couleur-texte 12)  ; 6 = vert. Essaie 11 (bleu clair)
(var background-color-menu 0)  ; 12 = Blanc. Essaie 0 (Noir)
(var background-color-game 6)

(fn _G.BOOT []
  (pmem 0 0))

(set best-score (pmem 0))
(global map-sol [])
(for [i 1 17]
  (local map-x []) ; new table each time
  (for [j 1 18]
    (tset map-x j (math.random 100)))
  (tset map-sol i map-x))

; Variable pour l'animation
(var t 0)

(fn restart-game []
  (set best-score 0)
  (set player-x 120)
  (set player-y 68)
  (set player-sprite 1)
  (set axis-x 0)
  (set axis-y 0)
  (set correct false)
  (set music-state -1)
  (set music-start-time 0)
  (set game-start-time 0)

  (set is-initializing-game false)

  (set chad-mult 1)
  (set chad-fly-spawned false)

; Flies
  (set flies []) ; {fly-pos-x, fly-pos-y, fly-vector-x, fly-vector-y, fly-respawn-delay}
; (global dead-flies-counter []) ; Counters of dead flies.

  (set must-play-sfx false)

  (set score 0)

  (set nutr-x 6)
  (set nutr-y 0)
  (set nutr-index 0)
  (set nutr-temps 120)
  (set nutr-delai nutr-temps)
  (set nutr-affiche 0)

  (set best-score (pmem 0))
  (set map-sol [])
  (for [i 1 17]
    (local map-x []) ; new table each time
    (for [j 1 18]
      (tset map-x j (math.random 100)))
    (tset map-sol i map-x))

; Variable pour l'animation
  (set t 0)
  (set state 0)) ; 0: start, 1: playing, 2: game over.

(fn play-music [musi]
  (music musi)
  (set music-start-time t)
  (set music-state musi))

(fn reset-music-game []
  (music -1)
  (set music-start-time 0)
  (set music-state -1)
  (set game-start-time t))

(fn start-game-music-logic []
  (set game-start-time t)
  (music -1)
  (set music-state -1))

(fn switch-state [btn next-state]
  (if (= true btn)
    (set state next-state)))

(fn render-start-menu []
  (if (not= music-state 1)
    (play-music 1))
  (cls background-color-menu)

  (var decalage-y (* (math.sin t) 2))
  
  ; Start menu title and sub.
  (for [i 0 29]
    (for [j 0 29]
      (spr 7 (* i 8) (* j 8) 0)))

  (print (.. "Best Score:\n" best-score) 4 4 couleur-texte true 1 true)

  (print "Dodge!" 105 (+ 50 decalage-y) couleur-texte)
  (print "Press space to start" 85 (+ 80 decalage-y) couleur-texte false 1 true)

  (print "By QbitSoft" 190 125 couleur-texte true 1 true)

  (spr 5 (- 15 32) (- 35 32) 0 8)
  (spr 6 (+ 15 32) (- 35 32) 0 8)
  (spr 21 (- 15 32) (+ 35 32) 0 8)
  (spr 22 (+ 15 32) (+ 35 32) 0 8)
  (spr 1 15 35 0 8)
  (spr 33 165 35 0 8))

(fn change-state [sfx-id sfx-note new-state]
  (sfx sfx-id sfx-note (* 60 3))
  (set state new-state)
  (set is-initializing-game true))

(fn manage-start-menu [] ; State 0. Start menu.
  (render-start-menu)

  ; QUAND bouton flèche haut préssée Jouer un son et passe en mode jeu si on est dans le start menu
  (if (= true (keyp 48))
    (change-state 0 c5 1)))

(fn detecte-oob [x y min-x max-x min-y max-y]
  (set correct false)
  (if (< x min-x)
    (set correct true))
  (if (> (+ x 8) max-x)
    (set correct true))
  (if (< y min-y)
    (set correct true))
  (if (> (+ y 8) max-y)
    (set correct true)))

(fn detect-collision [ax ay aw ah bx by bw bh]
  (and (and (< ax (+ bx bw)) (> (+ ax aw) bx)) (and (< ay (+ by bh)) (> (+ ay ah) by))))

(fn manage-player-movements []
  (if (= true (btn 0))
    (set axis-y (- axis-y 1)))
  (if (= true (btn 1))
    (set axis-y (+ axis-y 1)))
  (if (= true (btn 2))
    (set axis-x (- axis-x 1)))
  (if (= true (btn 3))
    (set axis-x (+ axis-x 1)))
  
  (detecte-oob (+ player-x axis-x) player-y GAME_MIN_X GAME_MAX_X GAME_MIN_Y GAME_MAX_Y)
  (if (= true correct)
    (set axis-x 0))
  (detecte-oob player-x (+ player-y axis-y) GAME_MIN_X GAME_MAX_X GAME_MIN_Y GAME_MAX_Y)
  (if (= true correct)
    (set axis-y 0))

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
  
(fn spaw-chad []
  (set music-main 0)
  (set chad-fly-spawned true))

(fn new-fly [pos-x pos-y dir-start-x dir-start-y dir-end-x dir-end-y velocity is-chad]
  ; ->AB=((xb-xa)*->i)+((yb-ya)*->i)
  (local vector-x (- dir-end-x dir-start-x))
  (local vector-y (- dir-end-y dir-start-y))
  (set velo (* velocity chad-mult))
  ;(if (> chad-mult chad-mod-lvl)
  ;  (set music-main 0))
  (table.insert flies {:fly-pos-x pos-x :fly-pos-y pos-y :fly-vector-x (* velo vector-x) :fly-vector-y (* velo vector-y) :is-chad is-chad}))

(fn spawn-flies []
  (local spawn-zone (math.random 0 1))
  (var start-x (math.random 0 40))
  (if (= 1 spawn-zone)
    (set start-x (math.random 200 240)))
  (local start-y (math.random 0 136))
  (var must-chad (and (< chad-mod-lvl chad-mult) (not chad-fly-spawned)))
  (if (= true must-chad)
    (spaw-chad))

  (new-fly start-x start-y start-x start-y (math.random 0 240) (math.random 0 136) (* chad-mult 0.002) must-chad))

(fn remove-fly [j]
  (table.remove flies j)
  (spawn-flies))

(fn move-flies []
  ; (trace "Tdmsldvs")
  (each [j value (pairs flies)]
    (tset value :fly-pos-x (+ (. value :fly-vector-x) (. value :fly-pos-x)))
    (tset value :fly-pos-y (+ (. value :fly-vector-y) (. value :fly-pos-y)))
    (detecte-oob (. value :fly-pos-x) (. value :fly-pos-y) 0 240 -16 152)
    (if (= true correct)
      (remove-fly j))

    (if (detect-collision player-x player-y 8 8 (. value :fly-pos-x) (. value :fly-pos-y) 8 8)
      (change-state 3 c3 2))))

(fn render-ombre-mouche1 [x y]
  (spr 192 (- x 4) (- y 4) 0)
  (spr 193 (+ x 4) (- y 4) 0)
  (spr 208 (- x 4) (+ y 4) 0)
  (spr 209 (+ x 4) (+ y 4) 0))

(fn render-ombre-mouche2 [x y]
  (spr 194 (- x 12) (- y 12) 0 3)
  (spr 195 (+ x 12) (- y 12) 0 3)
  (spr 210 (- x 12) (+ y 12) 0 3)
  (spr 211 (+ x 12) (+ y 12) 0 3))

(fn render-ombre-mouche3 [x y]
  (spr 196 (- x 12) (- y 12) 0 3)
  (spr 197 (+ x 12) (- y 12) 0 3)
  (spr 212 (- x 12) (+ y 12) 0 3)
  (spr 213 (+ x 12) (+ y 12) 0 3))

(fn render-flies []
  (each [key value (pairs flies)]
    (var sprite-randomizer 16)
    (var size 3)

    (if (= true (. value :is-chad))
      (set sprite-randomizer 18)
      (set size 1))

    (spr 34 (. value :fly-pos-x) (+ (. value :fly-pos-y) 4) 0)

    (local sprite (math.random sprite-randomizer (+ 1 sprite-randomizer)))
    (if (= sprite 17)
      (render-ombre-mouche1 (. value :fly-pos-x) (. value :fly-pos-y))
      (= sprite 18)
      (render-ombre-mouche2 (. value :fly-pos-x) (. value :fly-pos-y))
      (= sprite 19)
      (render-ombre-mouche3 (. value :fly-pos-x) (. value :fly-pos-y)))
    (spr sprite (. value :fly-pos-x) (. value :fly-pos-y) 0 size)))

(fn manage-flies []
  (if (= true is-initializing-game)
    (for [i 0 5 1]
      (spawn-flies)))
  (set is-initializing-game false)
  ;(trace-flies)
  (move-flies)
  (render-flies))

(fn render-game []
  
  (if (= game-start-time 0)
    (start-game-music-logic))
  (if (and (not= music-main music-state) (>= (- t game-start-time) (* 3 4)))
    (play-music music-main))
  (if (and (>= (- t music-start-time) (* 38 6)) (not= music-state -1))
    (reset-music-game))
  (cls background-color-game)

  (map)

  (for [i 1 (length map-sol)]
    (local inner (. map-sol i))
    (for [j 1 (length inner)]
      (if (< (. inner j) 41) ; Vide : 40 %
        (spr 48 (* (+ j 5) 8) (* (- i 1) 8) 0)
        (< (. inner j) 61) ; Fleurs : 20 %
        (spr ( + 64 (% t 4)) (* (+ j 5) 8) (* (- i 1) 8) 0)
        (< (. inner j) 81) ; Herbe : 20 %
        (spr ( + 80 (% t 6)) (* (+ j 5) 8) (* (- i 1) 8) 0)
        (< (. inner j) 86) ; Flaque : 5 %
        (spr ( + 96 (% t 6)) (* (+ j 5) 8) (* (- i 1) 8) 0)
        (< (. inner j) 100) ; Cailloux : 14 %
        (spr 112 (* (+ j 5) 8) (* (- i 1) 8) 0)
        (spr 113 (* (+ j 5) 8) (* (- i 1) 8) 0))))) ; Fenouil : 1%

<import generate-nutriment.fnl>

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
    (sfx 2 c6 -1))
  
  (if (= nutr-index 32)
    (set chad-mult (* 1.01 chad-mult))
    (set chad-mult (* 1.05 chad-mult))))

(fn manage-main-game []
  (render-game)

  (if (= nutr-affiche 0)
    (if (> nutr-delai 0)
      (set nutr-delai (- nutr-delai 1))
      (generate-nutriment))
    (render-nutriment))
  
  (if (= true (detect-collision player-x player-y 8 8 nutr-x nutr-y 8 8))
    (manage-ingere-nutriment))
  
  (manage-player-movements)
  (manage-flies)
  
  (for [i 0 5]
    (for [j 0 16]
      (spr 7 (* i 8) (* j 8))))
  
  (for [i 24 29]
    (for [j 0 16]
      (spr 7 (* i 8) (* j 8))))
      
  (print (.. "Score:\n" score) 4 4 couleur-texte true 1 true)
  (print (.. "Best Score:\n" best-score) 4 20 couleur-texte true 1 true))

(fn change-state [sfx-id sfx-note new-state]
  (sfx sfx-id sfx-note -1)
  (set state new-state))

(fn render-game-over []
  (cls background-color-menu)
  (set music-main 2)
  (if (or (= music-state 2) (= music-state 0))
    (reset-music-game))
  (if (not= 3 music-state)
    (play-music 3))

  (var decalage-y (* (math.sin t) 2))
  
  (for [i 0 29]
    (for [j 0 29]
      (spr 7 (* i 8) (* j 8) 0)))

  (print (.. "Score:\n" score) 4 4 couleur-texte true 1 true)

  (print (.. "Best Score:\n" best-score) 4 20 couleur-texte true 1 true)

  (print "Press space to restart" 80 (+ 100 decalage-y) couleur-texte false 1 true)
  
  (spr 4 85 10 0 8))

(fn manage-game-over []
  (if (> score best-score)
    (set best-score score))
  (render-game-over)
  (pmem 0 best-score)
  (if (= true (keyp 48))
    (restart-game)
  ))

; Boucle principale exécutée à 60 FPS
(fn _G.TIC []
  
  (if (= state 0)
    (manage-start-menu)
    )
  
  (if (= state 1)
    (manage-main-game))
  
  (if (= state 2)
    (manage-game-over))
  
  ; 4. Fait avancer le temps
  (set t (+ t 0.1)))