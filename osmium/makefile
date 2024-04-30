all:
	dune exec osmium "../documentation/images/sh.jpeg" 1.0

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


# ../documentation/images/gmk166x100.jpeg
# ../documentation/images/ws200x200.jpeg
# ../documentation/images/gg1000.jpeg
# ../documentation/images/ia1200x800.jpeg
# ../documentation/images/CL1600x500.jpeg
