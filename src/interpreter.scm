(module marrow-interpreter (interpret)
	(import scheme chicken.base srfi-1)

	(define built-in-values (list
				  (cons "nil" '())
				  (cons "fn" (lambda (nodes)
					       (if (< (length nodes) 2)
						 "Too few arguments to lambda function"
						 (case (caar nodes)
						   ((identifier) )
						   ((list)
						    (if (not (every (lambda (x) (equal? (car x) 'identifier)) (cdar nodes)))
						      "Argument list to lambda should consist of only identifiers"
						      `(lambda ,(map cddar nodes) (interpret ,(cadr)))))
						   (else "Arguments for a lambda should be an identifier or a list of identifiers")))))
				  (cons "+" (lambda (nodes) 
					   (apply + (map cdr nodes)))))) ; TODO: error handling if not integers

	(define (appl proc arguments)
	  (if (procedure? proc)
	    (proc arguments)
	    (string-append "Error: tried to call non-procedure value")))

	(define (interpret node)
	  (let ((type (car node)) (value (cdr node)))
	    (case type

	      ((integer string) value) ; return: simple value. TODO: strings should be quoted lists of chars

	      ((identifier)
	       (let ((built-in (assoc value built-in-values)))
		 (if built-in
		   (cdr built-in)
		   "TODO: implement non-built-in")))

	      ((list)
	       (if (null? value)
		 value ; return: nil
		 (appl (interpret (car value)) (cdr value))))

	      (else "TODO: implement")))))
