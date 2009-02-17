all: compile test

compile:
	mkdir -p ./ebin
	mkdir -p ./test/ebin
	erl -make

clean:
	rm -rf ./ebin/*.beam
	rm -rf ./test/ebin/*.beam

test: compile
	erl -noshell -pa ./ebin -pa ./test/ebin -s test_suite test -s init stop
