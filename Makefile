all:
	mkdir build && raco exe -o build/main-p2p src/main-p2p.rkt

clean:
	rm -rf build *.data src/*.rkt~ src/compiled src/errortrace

deps:
	raco pkg install --skip-installed crypto-lib sha threading

run:
	racket src/main-p2p.rkt

test:
	raco test tests/run-all-tests.rkt
