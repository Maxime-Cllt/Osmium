all:
	dune exec osmium "../documentation/images/gmk166x100.jpeg" 0.1

perf:
	dune build --profile=release
	dune exec osmium

test:
	dune runtest

install:
	dune install

uninstall:
	dune uninstall

clean:
	dune clean
	./clean.sh
