(import srfi-78)
(include "src/tokenizer.scm")
(import marrow-tokenizer)

(check-set-mode! 'summary)

; try-identifier
(check (try-identifier "name" 0) => (make-token 'identifier "name"))
(check (try-identifier "name " 0) => (make-token 'identifier "name"))
(check (try-identifier " name " 1) => (make-token 'identifier "name"))
(check (try-identifier "        \t\n name " 11) => (make-token 'identifier "name"))
(check (try-identifier "1 " 0) => #f)
(check (try-identifier "x " 0) => (make-token 'identifier "x"))
(check (try-identifier "x y" 0) => (make-token 'identifier "x"))

; try-string
(check (try-string "\"hello\"" 0) => (make-token 'string "hello"))
(check (try-string "\"hello" 0) => #f)
(check (try-string "hello\"" 0) => #f)
(check (try-string "\"hello\"" 1) => #f)
(check (try-string "1" 0) => #f)

; tokenize
(check (tokenize "(") => `(,(make-token 'symbol #\( )))
(check (tokenize ")") => `(,(make-token 'symbol #\) )))
(check (tokenize "name") => `(,(make-token 'identifier "name")))
(check (tokenize "    ( \n  ) \t") => `(
			     ,(make-token 'symbol #\( )
			     ,(make-token 'symbol #\) )))
(check (tokenize "x ") => `(,(make-token 'identifier "x")))
(check (tokenize "x y") => (list
				      (make-token 'identifier "x")
				      (make-token 'identifier "y")))
(check (tokenize "name )") => (list
				      (make-token 'identifier "name")
				      (make-token 'symbol #\) )))
(check (tokenize "( name )") => (list
				      (make-token 'symbol #\( )
				      (make-token 'identifier "name")
				      (make-token 'symbol #\) )))
(check (tokenize "\"some string\"") => `(,(make-token 'string "some string")))


(check (tokenize "(defn add (x y) (+ x y))") => (list
						  (make-token 'symbol #\()
						  (make-token 'identifier "defn")
						  (make-token 'identifier "add")
						  (make-token 'symbol #\()
						  (make-token 'identifier "x")
						  (make-token 'identifier "y")
						  (make-token 'symbol #\))
						  (make-token 'symbol #\()
						  (make-token 'identifier "+")
						  (make-token 'identifier "x")
						  (make-token 'identifier "y")
						  (make-token 'symbol #\))
						  (make-token 'symbol #\))))

(check-set-mode! 'report-failed)
(check-report)
