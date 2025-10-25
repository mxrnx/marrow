(module marrow-interpreter (interpret)
	(import scheme)

	(define (interpret node)
	  (case (car node)
	    ((integer string) (cadr node))
	    (else "TODO: implement"))))
