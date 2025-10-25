(import srfi-78)
(include "src/tokenizer")
(import marrow-tokenizer)

(include "src/parser.scm")
(import marrow-parser)

(check-set-mode! 'summary)

; basic values
(check (parse `(,(make-token 'integer 42))) => (make-node 'integer 42))
(check (parse `(,(make-token 'integer -3))) => (make-node 'integer -3))
(check (parse `(,(make-token 'identifier "function-name"))) => (make-node 'identifier "function-name"))
(check (parse `(,(make-token 'string "hello world"))) => (make-node 'string "hello world"))
(check (parse `(,(make-token 'symbol #\)))) => "Error: unexpected right parenthesis")

; lists
(check (parse `(,(make-token 'integer 42))) => (make-node 'integer 42))
(check (parse (list
		(make-token 'symbol #\( )
		(make-token 'identifier "thing")
		(make-token 'symbol #\) ))) => (make-node 'list `(,(make-node 'identifier "thing"))))
(check (parse (list
		(make-token 'symbol #\()
		(make-token 'identifier "thing"))) => "Error: missing right parenthesis")

; nested lists
(check (parse (list
		(make-token 'symbol #\( )
		(make-token 'symbol #\( )
		(make-token 'integer 25)
		(make-token 'symbol #\) )
		(make-token 'symbol #\) ))) => (make-node 'list (list (make-node 'list (list (make-node 'integer 25))))))
(check (parse (list
		(make-token 'symbol #\( )
		(make-token 'integer 1)
		(make-token 'integer 2)
		(make-token 'integer 3)
		(make-token 'symbol #\( )
		(make-token 'integer 25)
		(make-token 'symbol #\) )
		(make-token 'symbol #\) ))) => (make-node 'list 
							  (list 
							    (make-node 'integer 1)
							    (make-node 'integer 2)
							    (make-node 'integer 3)
							    (make-node 'list (list (make-node 'integer 25))))))
(check (parse (list
		(make-token 'symbol #\( )
		(make-token 'symbol #\( )
		(make-token 'integer 25)
		(make-token 'symbol #\) )
		(make-token 'integer 7)
		(make-token 'symbol #\( )
		(make-token 'integer 26)
		(make-token 'symbol #\) )
		(make-token 'symbol #\) ))) => (make-node 'list 
							  (list 
							    (make-node 'list (list (make-node 'integer 25)))
							    (make-node 'integer 7)
							    (make-node 'list (list (make-node 'integer 26)))
							    )))

(check-set-mode! 'report-failed)
(check-report)
