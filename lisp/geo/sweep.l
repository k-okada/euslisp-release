(list "@(#)$Id: sweep.l,v 1.1.1.1 2003/11/20 07:46:29 eus Exp $")
(defun sweep-body (bod direction length)
   "(bod direction length) returns a body made by sweeping the convex-hull
points of BOD in DIRECTION"
   (let* ((pnt (send bod :extream-point (scale -1.0 direction)))
	  (projection-plane (make-plane :normal direction :point pnt))
	  (contour-points
		(mapcar #'(lambda (v) (send projection-plane :project v))
			(send bod :vertices))))
;     (setq *points* (remove-duplicates contour-points :test #'equal))
     (make-prism  (reverse (quickhull contour-points direction))
		  (scale length direction))))


(defun remove-inner-loop (Vfaces Ifaces direction edge-loop)
"Visible-faces Invisible-faces normal edge-loop:
((edge1 (param1 point1) (param2 point2)) (edge2	(param2 ...)))"
   (let* ((kill nil)
	 (tracep1 edge-loop)
	 (tracep2 (cdar tracep1))
	 (tracing-edge (caar tracep1))
	 flag
	 (adjfaces (list (send tracing-edge :pface)
			 (send tracing-edge :nface)))
	 (-direction (v- direction)) 
	 px midp new-loop result)
      (labels ((next-point ()
		   (cond ((cdr tracep2)
			  (prog1 tracep2 (setq tracep2 (cdr tracep2))))
			 ((cdr tracep1)
			  (setq tracep1 (cdr tracep1)
			        tracep2 (cdar tracep1)
				tracing-edge (caar tracep1)
				adjfaces (list (send tracing-edge :pface)
					       (send tracing-edge :nface)))
			  (prog1 tracep2 (setq tracep2 (cdr tracep2))))
			 (t nil)))
		(inner-point-p (p &aux flag flag2)
		   (dolist (f Ifaces)
		      (unless (memq f adjfaces)
			 (setq flag (send f :intersect-point-vector
					  p direction))
		         (cond ((eql (car flag) :inside)
			    	 (return-from inner-point-p :inside))
				((eq (car flag) :border)
				 (setq flag2 flag))) ) )
		   (dolist (f Vfaces)
		      (unless (memq f adjfaces)
		         (setq flag (send f :intersect-point-vector
					  p -direction))
		         (cond ((eql (car flag) :inside)
			    	 (return-from inner-point-p :inside))
			       ((eql (car flag) :border)
				 (setq flag2 flag))) ) )
		   (if  flag2 (car flag2))
		   :outside  )
		(connect-lines (l1 l2)
		    (cond ((eps= (line-nvert l1) (line-pvert l2))
			   (setf (line-nvert l1) (line-nvert l2)))
			  ((eps= (line-nvert l1) (line-nvert l2))
			   (setf (line-nvert l1) (line-pvert l2)))
			  ((eps= (line-pvert l1) (line-nvert l2))
			   (setf (line-pvert l1) (line-pvert l2)))
			  ((eps= (line-pvert l1) (line-pvert l2))
			   (setf (line-pvert l1) (line-nvert l2))))
		    l1))
        (cond ((some #'cdddr edge-loop)
		(print "intersection")
		(while (setq px (next-point))
		   (setq midp (midpoint 0.5 (second (first px)) (second (second px))))
		   (setq flag (inner-point-p midp))
		   (unless (eql flag :inside)
			(push (second (car px)) new-loop)))
		(setq new-loop (cons (car new-loop) (nreverse new-loop)))
		(while (cdr new-loop)
		   (push (make-line (pop new-loop) (car new-loop)) result)))
	      (t
		(print "no intersection")
		(setq px (next-point))
		(setq midp (midpoint 0.5 (second (first px)) (second (second px))))
		(setq flag (inner-point-p midp))
		(if (eql flag :inside)
		    nil
		    (progn
			(setq new-loop (cons (cadr (cadr (car edge-loop)))
				(mapcar #'(lambda (x) (cadr (caddr x))) edge-loop)))
			(while (cdr new-loop)
			   (push (make-line (pop new-loop) (car new-loop))
				 result)))) ))
      (setq new-loop nil)
      (let* ((loop  (nreverse result))
	     (l1 (pop loop)) l2)
         (while loop
	    (if (send l1 :colinear-line (setq l2 (pop loop)) 0.001)
	        (setq l1 (connect-lines l1 l2) l2 nil) 
	        (progn (push l1 new-loop)
		       (setq l1 l2)) ))
	 (cond (new-loop
		(setq l2 (car (last new-loop)))
		(cond ((send l1 :colinear-line l2) (connect-lines l2 l1))
		      (t (push l1 new-loop)))
		(instance polygon :init :edges (nreverse new-loop)) ))
	 ))))

(defun project (bod pln)
  (let* (Vfaces Ifaces Contour-edges contour-edge-loops Contour-vertices
	 (vnormal (send pln :normal)) 	(-vnormal (v- vnormal))
	 x y loop shadow-loops shadows)
      (dolist (f (send bod :faces))
	  (if (eps< (v. vnormal (plane-normal f)) 0.0 )
	      (push f Vfaces)
	      (push f Ifaces)))
      (dolist (e (send bod :edges))
	  (if (or  (and (member (edge-pface e) Vfaces)
			(member (edge-nface e) Ifaces))
		   (and (member (edge-nface e) Vfaces)
			(member (edge-pface e) Ifaces)))
	      (push (list e) contour-edges)))
      (dolist (e contour-edges)
	 (let ((pv (edge-pvert (car e))) (nv (edge-nvert (car e))) x)
	    (unless (assoc pv contour-vertices)
		(push (list pv (send pln :project pv)) contour-vertices))
	    (unless (assoc nv contour-vertices)
		(push (list nv (send pln :project nv)) contour-vertices))) )
      (dolist (e contour-edges)
	 (let ((pv (edge-pvert (car e))) (nv (edge-nvert (car e))))
	    (nconc e (list (list 0.0 (cadr (assoc pv contour-vertices))))
		     (list (list 1.0 (cadr (assoc nv contour-vertices)))) )))
      ;; find closed loops
      (while contour-edges
	 (setq loop nil)
	 (setq x (pop contour-edges))
         (push x loop)
         (setq x (second (third x)))
	 (while (setq y (find-if 
		      #'(lambda (ce) (or (eq (second (second ce)) x)
					 (eq (second (third ce)) x)) )
		      contour-edges))
	     (setq  contour-edges (delete y contour-edges :count 1))
	     (unless (eq (second (second y)) x) 
		  (setq y (list (car y) (list 0.0 (second (third y)))
					(list 1.0 (second (second y))))) )
	     (setq x (second (third y)))
	     (push y loop))
	 (push (nreverse loop) contour-edge-loops))
      (nreverse contour-edge-loops)
      ;; find intersections
      (dolist (edge-loop contour-edge-loops)
         (do-combination (e1 e2 edge-loop)
	    (let* ((pv1 (second (second e1)))
		  (nv1 (second (third e1)))
		  (pv2 (second (second e2)))
		  (nv2 (second (third e2)))
		  (intersects (line-intersection #|3|# pv1 nv1 pv2 nv2))
		  param1 param2  point)
	       (when intersects
		   (setq param1 (first intersects)
			 param2 (second intersects))
		   (setq point (midpoint param1 pv1 nv1))
		   (when (and (eps< 0.0 param1) (eps< param1 1.0)
			    (eps< 0.0 param2) (eps< param2 1.0))
		       (setq point (midpoint param1 pv1 nv1))
		       (nconc e1 (list (list param1 point)))
		       (nconc e2 (list (list param2 point)))))
	       )   
	    )
	 (dolist (elist edge-loop)
	    (rplacd elist (sort (cdr elist) #'<= #'first)))
	 )
      (dolist (edge-loop contour-edge-loops)
	 (setq loop
	 	(remove-inner-loop Vfaces Ifaces vnormal edge-loop))
	 (if loop (push loop shadow-loops)))
   ;;      (do-combination (s1 s2 (nreverse shadow-loops)))
     (nreverse shadow-loops)	 ) )
