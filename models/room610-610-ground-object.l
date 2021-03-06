;;
;; DO NOT EDIT THIS FILE
;; this file is automatically generated from euslisp+euslib version 
;;
;;
(defclass room610-610-ground-object
  :super cascaded-link
  :slots (sensors
         ))
(defmethod room610-610-ground-object
  (:init
   (&rest args &key (name "room610-610-ground") (pos (float-vector 0 0 0)) (rot (unit-matrix 3)) &allow-other-keys)
   (let (c bc
         blink0
                 )
     (send-super* :init :name name args)

     ;; definition of link

     ;; definition of :room610-610-ground-bodyset2
     (setq bc (list
       (instance faceset :init :faces (list
         (instance face :init :vertices (list (float-vector 3750.0 2500.0 5.0) (float-vector -3750.0 2500.0 5.0) (float-vector -3750.0 -2500.0 5.0) (float-vector 3750.0 -2500.0 5.0)))
         (instance face :init :vertices (list (float-vector -3750.0 2500.0 -5.0) (float-vector 3750.0 2500.0 -5.0) (float-vector 3750.0 -2500.0 -5.0) (float-vector -3750.0 -2500.0 -5.0)))
         (instance face :init :vertices (list (float-vector 3750.0 2500.0 5.0) (float-vector 3750.0 2500.0 -5.0) (float-vector -3750.0 2500.0 -5.0) (float-vector -3750.0 2500.0 5.0)))
         (instance face :init :vertices (list (float-vector 3750.0 -2500.0 5.0) (float-vector 3750.0 -2500.0 -5.0) (float-vector 3750.0 2500.0 -5.0) (float-vector 3750.0 2500.0 5.0)))
         (instance face :init :vertices (list (float-vector -3750.0 -2500.0 5.0) (float-vector -3750.0 -2500.0 -5.0) (float-vector 3750.0 -2500.0 -5.0) (float-vector 3750.0 -2500.0 5.0)))
         (instance face :init :vertices (list (float-vector -3750.0 2500.0 5.0) (float-vector -3750.0 2500.0 -5.0) (float-vector -3750.0 -2500.0 -5.0) (float-vector -3750.0 -2500.0 5.0)))
       ))
       ))
     (dolist (b (cdr bc)) (send (car bc) :assoc b))
     ;; paste texture 610-floor-tex.jpg
     (send (elt bc 0) :paste-texture-to-face (elt (send (elt bc 0) :faces)0) :file "models/610-floor-tex.jpg")
     (send (elt bc 0) :set-color :black)
     (setq blink0 (instance bodyset-link :init (make-cascoords) :bodies bc :name :room610-610-ground-bodyset2 :weight 1 :centroid (float-vector 0.0 0.0 0.0) :inertia-tensor #2f((1.0 0.0 0.0) (0.0 1.0 0.0) (0.0 0.0 1.0))))

     ;; definition of assoc
     (send self :assoc blink0)

     ;; definition of end-coords

     ;; definition of joint


     ;; init-ending 
     (setq links (list blink0))
     (setq joint-list (list))
     (send self :init-ending)
     (send self :move-to (make-coords :pos pos :rot rot))
     (send-all links :worldcoords)

     self))

  (:handle (&rest args) (forward-message-to-all (list ) args))
  (:attention (&rest args) (forward-message-to-all (list ) args))
  (:button (&rest args) (forward-message-to-all (list ) args))
  )

(defun room610-610-ground (&rest args) (instance* room610-610-ground-object :init args))
;; (format *error-output* "(instance room610-610-ground-object :init) for generating model~%")
