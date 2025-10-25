(include "src/tokenizer.scm")
(include "src/parser")
(include "src/interpreter")
(import marrow-tokenizer marrow-parser marrow-interpreter)

(display (interpret (parse (tokenize "((fn (a b) (+ a b)) 1990 9)"))))
