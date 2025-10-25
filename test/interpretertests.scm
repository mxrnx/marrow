(import srfi-78)

(include "src/parser.scm")
(include "src/interpreter.scm")
(import marrow-parser marrow-interpreter)

(check-set-mode! 'summary)

; simple values
(check (interpret (make-node 'integer 1999)) => 1999)
(check (interpret (make-node 'string "hello world")) => "hello world")

(check-set-mode! 'report-failed)
(check-report)
