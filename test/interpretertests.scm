(import srfi-78)

(include "src/parser.scm")
(include "src/interpreter.scm")
(import marrow-parser marrow-interpreter)

(check-set-mode! 'summary)

; simple values
(check (interpret (make-node 'integer 1999)) => 1999)
(check (interpret (make-node 'string "hello world")) => "hello world") ; TODO: invalidate this case?

; built-in values
(check (interpret (make-node 'identifier "nil")) => '())
(check (procedure? (interpret (make-node 'identifier "+"))) => #t)

; function application
(check (interpret (make-node 'list (list (make-node 'integer 3)))) => "Error: tried to call non-procedure value")
(check (interpret (make-node 'list (list 
				     (make-node 'identifier "+")
				     (make-node 'integer 10)
				     (make-node 'integer 12)))) => 22)

; lambda failure modes
(check (interpret (make-node 'list (list (make-node 'identifier "fn")))) => "Too few arguments to lambda function")
(check (interpret (make-node 'list (list
				     (make-node 'identifier "fn")
				     (make-node 'integer 1)
				     (make-node 'identifier "i")))) => "Arguments for a lambda should be an identifier or a list of identifiers")
(check (interpret (make-node 'list (list
				     (make-node 'identifier "fn")
				     (make-node 'list (list (make-node 'integer 1)))
				     (make-node 'identifier "i")))) => "Argument list to lambda should consist of only identifiers")

; lambdas
;(check (interpret (make-node 'list (list
				     ;(make-node 'identifier "fn")
				     ;(make-node 'identifier "i")
				     ;(make-node 'identifier "i")))) => #t) ; TODO

; application
(check (interpret (make-node 'list (list 
				     (make-node 'list (list
					     (make-node 'identifier "fn")
					     (make-node 'identifier "i")
					     (make-node 'identifier "i")))
				     (make-node 'integer 9001)))) => 9001)

(check-set-mode! 'report-failed)
(check-report)
