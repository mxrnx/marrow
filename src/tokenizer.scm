(module marrow-tokenizer (tokenize make-token try-identifier try-string)
	(import scheme regex chicken.base srfi-13)

	(define (make-token type value) (cons type value))

	;; whitespace regex
	(define whitespace-rx (regexp "\\s"))

	;; helper: skip whitespace
	(define (skip-whitespace text index)
	  (let loop ((i index))
	    (if (and (< i (string-length text))
		     (string-match whitespace-rx (string (string-ref text i))))
	      (loop (+ i 1))
	      i)))

	;; subtokenizers
	(define (try-symbol text index)
	  (let ((ch (string-ref text index)))
	    (if (member ch '(#\( #\)))
	      (values (make-token 'symbol ch) (+ index 1))
	      (values #f index))))

	(define (try-integer text index)
	  (let* ((m (string-search (regexp "^[0-9]+") (substring text index))))
	    (if m
	      (let ((val (car m)))
		(values (make-token 'integer val)
			(+ index (string-length val))))
	      (values #f index))))

	(define (try-identifier text index)
	  ;(display (string-append text ":" (number->string index) "\n")) ; TODO
	  (let* ((substr (substring text index))
		 (m (string-search (regexp "^[A-Za-z_\\+\\-\\*\\/\\?!][A-Za-z_\\+\\-\\*\\/\\?!0-9]*") substr)))
	    (if m
	      (let ((val (car m)))
		(values (make-token 'identifier val)
			(+ index (string-length val))))
	      (values #f index))))


	(define (try-string text index)
	  (if (>= (+ index 1) (string-length text))
	    (values #f index)
	    (if (char=? (string-ref text index) #\")
	      (let* ((rest (substring text (+ index 1)))
		     (end (string-index rest #\")))
		(if end
		  (let ((val (substring rest 0 end)))
		    (values (make-token 'string val)
			    (+ index 2 end)))
		  (values #f index)))
	      (values #f index))))

	;; main tokenizer
	(define (tokenize text)
	  (let loop ((index 0) (tokens '()))
	    (if (>= index (string-length text))
	      (reverse tokens)
	      (let ((index (skip-whitespace text index)))
		(if (>= index (string-length text))
		  (reverse tokens)
		  (let ((attempts (list try-symbol try-integer try-identifier try-string)))
		    (let try-next ((subs attempts))
		      (if (null? subs)
			(string-append "Error: Could not tokenize at index " (number->string index) ", character '" (string (string-ref text index)) "'")
			(call-with-values
			  (lambda () ((car subs) text index))
			  (lambda (token new-index)
			    (if token
			      (loop new-index (cons token tokens))
			      (try-next (cdr subs))))))))))))))
