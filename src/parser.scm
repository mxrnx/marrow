(module marrow-parser (parse make-node)
	(import scheme)

	(define (make-node type value) (list type value))

	(define (format-error index) (string-append "Error: could not parse at index " (number->string index)))

	(define (parse-list tokens index)
	  (let loop ((nodes '()) (i index))
	    (if (>= i (length tokens))
	      (values #f 0)
	      (let ((token (list-ref tokens i)))
		(if (and (equal? (car token) 'symbol) (equal? (cadr token) #\))) ; end of list
		  (values (reverse nodes) (+ i 1))
		  (call-with-values
		    (lambda () (parse tokens i))
		    (lambda (node new-index)
		      (loop (cons node nodes) new-index))))))))

	(define (parse tokens index)
	  (let ((token (list-ref tokens index)))
	    (case (car token)
	      ((integer identifier string) (values token (+ index 1)))
	      ((symbol)
	       (case (cadr token)
		 ((#\()
		  (call-with-values
		    (lambda () (parse-list tokens (+ index 1)))
		    (lambda (inner-list new-index)
		      (if inner-list
			(values (make-node 'list inner-list) new-index)
			(values "Error: missing right parenthesis" index)))))
		 ((#\)) (values "Error: unexpected right parenthesis" index))
		 (else (values "Error: unknown symbol" index))))
	      (else (values "Error: could not parse" index))))))
