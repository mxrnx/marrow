(module marrow-interpreter (interpret interpret2 built-in-values lambda-builder cons-zip)
	(import scheme chicken.base srfi-1)

	(define (cons-zip left right)
	  (if (or (null? left) (null? right))
	    '()
	    (cons (cons (car left) (car right)) (cons-zip (cdr left) (cdr right)))))

	(define (lambda-builder argument-names body)
	  (lambda (args bindings)
	    (if (not (equal? (length args) (length argument-names)))
	      "Too few or many arguments to lambda function (internal)" ; todo better message here and below
	      (interpret2 
		body
		(append bindings 
			(cons-zip argument-names 
				  (map (lambda (y) (interpret2 y bindings)) args)))))))

	(define (node-identifier node) (if (equal? (car node) 'identifier) (cdr node) #f))
	(define (node-integer node) (if (equal? (car node) 'integer) (cdr node) #f))

	(define (binary-operator op-name op)
	  (cons op-name 
		(lambda (nodes bindings)
	    (if (not (equal? (length nodes) 2))
	      (string-append "Too few or many arguments to " op-name " form")
	      (let ((a (interpret2 (car nodes) bindings))
		    (b (interpret2 (cadr nodes) bindings)))
		(if (or (not (number? a)) (not (number? b)))
		  (string-append "Arguments to " op-name " must be numerical")
		  (op a b)))))))

	(define built-in-values (list
				  (cons "nil" '())
				  (cons "eval" (lambda (nodes bindings) (interpret2 (car nodes) bindings)))
				  (cons "do" (lambda (nodes bindings) 
					       (car (reverse (map (lambda (x) (interpret2 x bindings)) nodes))))) ; not yet interesting, as the language is pure so far
				  (cons "let" (lambda (nodes bindings)
						(if (not (equal? (length nodes) 3))
						  "Too few or many arguments to let form"
						  (let ((name (node-identifier (car nodes)))
							(value (interpret2 (cadr nodes) bindings)))
						    (interpret2 (caddr nodes) (append bindings (list (cons name value)))))
						  )))
				  (cons "fn" (lambda (nodes _bindings)
					       (if (not (equal? (length nodes) 2))
						 "Too few or many arguments to fn form"
						 (case (caar nodes)
						   ((identifier) (lambda-builder (list (cdar nodes)) (cadr nodes)))
						   ((list)
						    (if (not (every (lambda (x) (equal? (car x) 'identifier)) (cdar nodes)))
						      "Argument list to lambda should consist of only identifiers"
						      (let ((argument-names (map (lambda (x) (cdr x)) (cdar nodes))))
							(lambda-builder argument-names (cadr nodes)))))
						   (else "Arguments for a lambda should be an identifier or a list of identifiers")))))
				  (binary-operator "*" *)
				  (binary-operator "+" +)))

	(define (appl proc arguments bindings)
	  (if (procedure? proc)
	    (proc arguments bindings)
	    (string-append "Error: tried to call non-procedure value")))

	(define (interpret node) (interpret2 node '()))

	(define (interpret2 node bindings)
	  (let ((type (car node)) (value (cdr node)))
	    (case type

	      ((integer string) value) ; return: simple value. TODO: strings should be quoted lists of chars

	      ((identifier)
	       (let ((built-in (assoc value built-in-values))
		     (bound (assoc value bindings)))
		 (if built-in
		   (cdr built-in)
		   (if bound
		     (cdr bound)
		     (string-append "Unknown value '" value "'")))))

	      ((list)
	       (if (null? value)
		 value ; return: nil
		 (appl (interpret2 (car value) bindings) (cdr value) bindings)))

	      (else "TODO: implement")))))
