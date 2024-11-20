OBJECTS = code.o main.o

TEST_OBJ = code.o tests.o

# OS identification from: https://stackoverflow.com/questions/714100/os-detecting-makefile
OS := $(shell uname -s)

ifeq ($(OS), Darwin) 
  INCLUDE_PATH := /opt/homebrew/Cellar/criterion/2.4.1_1/include
  LIB_PATH := /opt/homebrew/Cellar/criterion/2.4.1_1/lib
  CC = gcc-12
endif
ifeq ($(OS), Linux) 
  INCLUDE_PATH := /util/criterion/include
  LIB_PATH := /util/criterion/lib/x86_64-linux-gnu
  CC = gcc
endif

CC = gcc
NO_DEBUG_FLAGS = -c -Wall -std=c11
DEBUG_FLAGS = -g -c -Wall -std=c11
FLAGS = $(DEBUG_FLAGS)

SRC = code.c main.c
TST = tests.c

FLAGS = -pg -fprofile-arcs -ftest-coverage
CFLAGS = -L $(LIB_PATH) -I $(INCLUDE_PATH)
CLIB = -lcriterion

EXE_FLAG := -g -Wall -O0 -fprofile-arcs -ftest-coverage -std=c11

.PHONY: clean andRunPerformance andRunCallGrind andRunTests

clean:
	rm -rf *~ *.o $(OBJECTS) $(TEST_OBJ) *.dSYM *.gc?? analyze.txt gmon.out *.gch main tests

code.o: code.c defs.h
	$(CC) $(EXE_FLAG) -c defs.h code.c

main.o: main.c defs.h
	$(CC) $(EXE_FLAG) -c main.c

tests.o: tests.c defs.h
	$(CC) -c -g -O0 -Wall -std=c11 -I $(INCLUDE_PATH) tests.c

main: code.o main.o
	$(CC) $(EXE_FLAG) $(OBJECTS) -o main

tests: $(TEST_OBJ)
	$(CC) -g -O0 -Wall -pg -fprofile-arcs -ftest-coverage -L $(LIB_PATH) -I $(INCLUDE_PATH) -o tests code.c tests.c -lcriterion

andRunTests: tests
	./tests


andRunCoverage:
	make clean
	make main
	gcov -abcfu code.c

andRunMemCheck:
	make clean
	make main
	valgrind --track-origins=yes --tool=memcheck --leak-check=yes ./main
	#valgrind --leak-check=yes ./main
