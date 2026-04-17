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