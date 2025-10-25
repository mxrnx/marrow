SRC_DIR = src
TEST_DIR = test
BIN = marrow
SRC = $(wildcard $(SRC_DIR)/*.scm)
SRC_MAIN = $(SRC_DIR)/main.scm
TESTS = $(wildcard $(TEST_DIR)/*.scm)

all: $(BIN)

$(BIN): $(SRC)
	csc -o $(BIN) $(SRC_MAIN)

test: $(BIN)
	@for t in $(TESTS); do \
		echo "==> $$t"; \
		csi -s $$t || exit 1; \
	done

clean:
	rm -f $(BIN) $(SRC_DIR)/*.o $(SRC_DIR)/*.c

install-deps:
	chicken-install srfi-78 # unit tests
	chicken-install srfi-13 # strings
	chicken-install regex

.PHONY: all test clean install-deps

