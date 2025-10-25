(import srfi-78)

(include "src/parser.scm")
(include "src/interpreter.scm")
(import marrow-parser marrow-interpreter)

(check-set-mode! 'summary)
(check-set-mode! 'off) ; TODO
(check-set-mode! 'summary) ; TODO

; simple values
(check (interpret (make-node 'integer 1999)) => 1999)
(check (interpret (make-node 'string "hello world")) => "hello world") ; TODO: invalidate this case?

; built-in values
(check (interpret (make-node 'identifier "nil")) => '())
(check (procedure? (interpret (make-node 'identifier "+"))) => #t)
(check (procedure? (lambda-builder '() (list (make-node 'integer 3)))) => #t)
(check ((lambda-builder '() (make-node 'integer 3)) '() '()) => 3)
(let* ((fn (cdr (assoc "fn" built-in-values)))
       (resulting-procedure (fn (list (make-node 'list '()) (make-node 'integer 3)) '())))
  (check (resulting-procedure '() '()) => 3))

; eval & do (multi-eval)
(check (interpret (make-node 'list (list (make-node 'identifier "eval") (make-node 'integer 55)))) => 55)
(check (interpret (make-node 'list (list (make-node 'identifier "do") (make-node 'integer 57) (make-node 'integer 58)))) => 58)

; + form
(check (interpret (make-node 'list (list (make-node 'identifier "+") (make-node 'integer 3) (make-node 'integer 1)))) => 4)
(check (interpret (make-node 'list (list (make-node 'identifier "+") (make-node 'integer 3)))) 
       => "Too few or many arguments to + form")
(check (interpret (make-node 'list (list (make-node 'identifier "+") (make-node 'integer 3) (make-node 'integer 1) (make-node 'integer 7)))) 
       => "Too few or many arguments to + form")
(check (interpret (make-node 'list (list (make-node 'identifier "+") (make-node 'string "3") (make-node 'integer 1)))) 
       => "Arguments to + must be numerical")

; * form
(check (interpret (make-node 'list (list (make-node 'identifier "*") (make-node 'integer 3) (make-node 'integer 3)))) => 9)
(check (interpret (make-node 'list (list (make-node 'identifier "*") (make-node 'integer 3)))) 
       => "Too few or many arguments to * form")
(check (interpret (make-node 'list (list (make-node 'identifier "*") (make-node 'integer 3) (make-node 'integer 1) (make-node 'integer 7)))) 
       => "Too few or many arguments to * form")
(check (interpret (make-node 'list (list (make-node 'identifier "*") (make-node 'string "3") (make-node 'integer 1)))) 
       => "Arguments to * must be numerical")

; bindings
(check (interpret2 (make-node 'identifier "x") '()) => "Unknown value 'x'")
(check (interpret2 (make-node 'identifier "x") (list (cons "x" 12))) => 12)
(check (interpret2 (make-node 'list (list
				      (make-node 'identifier "let")
				      (make-node 'identifier "forty-two")
				      (make-node 'integer 42)
				      (make-node 'identifier "forty-two"))) '()) => 42)

; lambda failure modes
(check (interpret (make-node 'list (list (make-node 'identifier "fn")))) => "Too few or many arguments to fn form")
(check (interpret (make-node 'list (list
				     (make-node 'identifier "fn")
				     (make-node 'integer 1)
				     (make-node 'identifier "i")))) => "Arguments for a lambda should be an identifier or a list of identifiers")
(check (interpret (make-node 'list (list
				     (make-node 'identifier "fn")
				     (make-node 'list (list (make-node 'integer 1)))
				     (make-node 'identifier "i")))) => "Argument list to lambda should consist of only identifiers")

; lambdas
(check (procedure? (interpret (make-node 'list (list
						 (make-node 'identifier "fn")
						 (make-node 'identifier "i")
						 (make-node 'identifier "i"))))) => #t)

(check (procedure? (interpret (make-node 'list (list
						 (make-node 'identifier "fn")
						 (make-node 'list '())
						 (make-node 'integer 20))))) => #t)
(check (procedure? (interpret (make-node 'list (list
						 (make-node 'identifier "fn")
						 (make-node 'list (list (make-node 'identifier "a") (make-node 'identifier "b")))
						 (make-node 'integer 20))))) => #t)

; application
(check (interpret (make-node 'list (list (make-node 'integer 3)))) => "Error: tried to call non-procedure value")
(check (interpret (make-node 'list (list 
				     (make-node 'list (list
							(make-node 'identifier "fn")
							(make-node 'list '())
							(make-node 'integer 26)))))) => 26)
(check (interpret (make-node 'list (list 
				     (make-node 'list (list
							(make-node 'identifier "fn")
							(make-node 'identifier "i")
							(make-node 'identifier "i")))
				     (make-node 'integer 9001)))) => 9001)

(check (interpret (make-node 'list (list 
				     (make-node 'list (list
							(make-node 'identifier "fn")
							(make-node 'list (list
									   (make-node 'identifier "a")
									   (make-node 'identifier "b")))
							(make-node 'identifier "a")))
				     (make-node 'integer 9001)
				     (make-node 'integer 9002)))) => 9001)

(check (interpret (make-node 'list (list 
				     (make-node 'list (list
							(make-node 'identifier "fn")
							(make-node 'list (list
									   (make-node 'identifier "a")
									   (make-node 'identifier "b")))
							(make-node 'list (list
									   (make-node 'identifier "+")
									   (make-node 'identifier "a")
									   (make-node 'identifier "b")))))
				     (make-node 'integer 9001)
				     (make-node 'integer 9002)))) => 18003)

(check (interpret (make-node 'list (list 
				     (make-node 'list (list
							(make-node 'identifier "fn")
							(make-node 'identifier "i")
							(make-node 'identifier "i")))
				     (make-node 'integer 9001)
				     (make-node 'integer 9002)))) => "Too few or many arguments to lambda function (internal)")

(check (interpret (make-node 'list (list 
				     (make-node 'list (list
							(make-node 'identifier "fn")
							(make-node 'list (list
									   (make-node 'identifier "a")
									   (make-node 'identifier "b")))
							(make-node 'list '())))
				     (make-node 'integer 9001)))) => "Too few or many arguments to lambda function (internal)")

; helper behavior
(check (cons-zip '("a" "b" "c") '(1 2 3)) => (list (cons "a" 1) (cons "b" 2) (cons "c" 3)))
(check (append (list (cons "a" 1) (cons "b" 2)) (list (cons "c" 3) (cons "d" 4))) => (list (cons "a" 1) (cons "b" 2) (cons "c" 3) (cons "d" 4)))

(check-set-mode! 'report-failed)
(check-report)
