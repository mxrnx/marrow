(module marrow-interpreter (interpret)
	(import scheme)

	(define (interpret node)
	  (case (car node)
	    ((integer string) (cdr node))
	    (else "TODO: implement"))))
