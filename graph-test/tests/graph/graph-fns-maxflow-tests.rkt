#lang racket

(require graph/graph-weighted
         graph/graph-unweighted
         graph/graph-fns-maxflow
         graph/gen-graph
         rackunit)

(define g26.1
  (mk-weighted-graph/directed
   '((16 s v1)
     (13 s v2)
     (10 v1 v2)
     (4 v2 v1)
     (12 v1 v3)
     (14 v2 v4)
     (9 v3 v2)
     (7 v4 v3)
     (20 v3 t)
     (4 v4 t))))

(define flow26.1 (maxflow g26.1 's 't))
(define (validate-flow g f s t)
  (define (out v) 
    (for/sum ([(e flow) (in-hash f)] #:when (equal? v (first e))) flow))
  (define (in v) 
    (for/sum ([(e flow) (in-hash f)] #:when (equal? v (second e))) flow))
  (for ([(e flow) (in-hash f)])
    (check-true (<= flow (apply edge-weight g e))))
  (check-equal? (out s) (in t))   ;; s outgoing = t incoming
  ;; flow conservation
  (for ([v (in-vertices g)] #:unless (or (equal? v s) (equal? v t)))
    (check-equal? (in v) (out v))))

(validate-flow g26.1 flow26.1 's 't)
(check-equal? (for/sum ([(e flow) (in-hash flow26.1)] 
                        #:when (equal? 's (first e))) flow)
              23)

(define g26.6 (mk-weighted-graph/directed '((1000000 s u)
                                            (1000000 u t)
                                            (1 u v)
                                            (1000000 s v)
                                            (1000000 v t))))

(define flow26.6 (maxflow g26.6 's 't))
(validate-flow g26.6 flow26.6 's 't)
(check-equal?
 flow26.6
 (make-immutable-hash '(((v t) . 1000000) ((s u) . 1000000) ((s v) . 1000000) ((u t) . 1000000))))

(define gsedge18.6 (mk-unweighted-graph/undirected '((0 2) (0 7) (0 5)
                                                     (2 6)
                                                     (6 4)
                                                     (7 1) (7 4)
                                                     (4 3) (4 5)
                                                     (3 5))))
(check-false (bipartite? gsedge18.6))

(define gsedge17.5 (mk-unweighted-graph/undirected '((0 1) (0 3) (0 5)
                                                     (1 2)
                                                     (2 9)
                                                     (3 4)
                                                     (4 5) (4 11)
                                                     (6 7) (6 9)
                                                     (7 8)
                                                     (8 9)
                                                     (9 10) (9 12)
                                                     (11 12))))
(define L-R (bipartite? gsedge17.5))
(check-not-false L-R)
(let ([computed-L (apply set (first L-R))]
      [computed-R (apply set (second L-R))]
      [L (set 0 2 4 6 8 10 12)]
      [R (set 1 3 5 7 9 11)])
  (check-true (or (and (equal? computed-L L)
                       (equal? computed-R R))
                  (and (equal? computed-L R)
                       (equal? computed-R L)))
              "bipartite graph 0,2,3,4,8,10,12 and 1,3,5,7,9,11"))

(define gwiki1 (mk-unweighted-graph/undirected '((0 1) (0 5) (0 6) (0 7)
                                                 (1 2) (1 4)
                                                 (2 3)
                                                 (3 4) (3 7)
                                                 (4 5)
                                                 (5 6)
                                                 (6 7))))
(check-false (bipartite? gwiki1))

(define gwiki2 (mk-unweighted-graph/undirected '((0 1) (0 5)
                                                 (1 2) (1 4)
                                                 (2 3)
                                                 (3 4)
                                                 (4 5))))
(define L-Rwiki2 (bipartite? gwiki2))
(check-not-false L-Rwiki2)
(let ([computed-L (apply set (first L-Rwiki2))]
      [computed-R (apply set (second L-Rwiki2))]
      [L (set 1 3 5)]
      [R (set 0 2 4)])
  (check-true (or (and (equal? computed-L L)
                       (equal? computed-R R))
                  (and (equal? computed-L R)
                       (equal? computed-R L)))
    "bipartite graph 1,3,5 and 0,2,4"))
                                                 
(define g26.8 
  (mk-unweighted-graph/undirected
   '((1 6) (2 6) (2 8) (3 7) (3 8) (3 9) (4 8) (5 8))))
(define L-R26.8 (bipartite? g26.8))
(check-not-false L-R26.8)
(define matching26.8 (maximum-bipartite-matching g26.8))
(check-equal? (length matching26.8) 3)
(check-true
 (set-empty?
  (set-intersect (map first matching26.8) (map second matching26.8))))
;; check no dups
(check-equal? (set-count (map first matching26.8))
              (set-count (list->set (map first matching26.8)))
              "no dups 1")
(check-equal? (set-count (map second matching26.8))
              (set-count (list->set (map second matching26.8)))
              "no dups 2")
(check-true (subset? (map first matching26.8) (second L-R26.8)))
(check-true (subset? (map second matching26.8) (first L-R26.8)))

(define bipartite-boost
  (mk-unweighted-graph/undirected
   '((0 1) (0 4) (1 2) (2 6) (3 4) (3 8) (4 5) (4 7) (5 6) (6 7) (7 10) (8 9) (9 10))))
(define L-R-boost (bipartite? bipartite-boost))
(check-not-false L-R-boost)
(check-equal? (list->set (map list->set L-R-boost))
              (set (set 1 6 4 8 10) (set 0 2 3 5 7 9)))

(define non-bipartite-boost 
  (mk-unweighted-graph/undirected 
   '((0 1) (0 4) (1 2) (2 6) (3 6) (3 8) (4 5) (4 7) (5 6) (6 7) (7 9) (8 9))))
(check-false (bipartite? non-bipartite-boost))

(define bipartite-cmu
  (mk-unweighted-graph/undirected '((a 1) (a 2)
                                    (b 1)
                                    (c 2) (c 3)
                                    (d 3) (d 4) (d 5)
                                    (e 5))))
(define L-R-cmu (bipartite? bipartite-cmu))
(check-not-false L-R-cmu)
(define matching-cmu (maximum-bipartite-matching bipartite-cmu))
;; should be complete matching
(check-equal? (length matching-cmu) 5)
(check-true
 (set-empty?
  (set-intersect (map first matching-cmu) (map second matching-cmu))))
;; check no dups
(check-equal? (set-count (map first matching-cmu))
              (set-count (list->set (map first matching-cmu))))
(check-equal? (set-count (map second matching-cmu))
              (set-count (list->set (map second matching-cmu))))
(check-equal? (list->set (map first matching-cmu)) ; every node matched
              (list->set (second L-R-cmu)))
(check-equal? (list->set (map second matching-cmu))
              (list->set (first L-R-cmu)))
