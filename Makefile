REPORTER = spec
BIN = ./node_modules/.bin

test:
		mocha --reporter $(REPORTER) build/test

coverage:
		$(MAKE) clean
		mkdir reports
		istanbul instrument -x "public/**" -x "test/**" --output build-cov build -v
		cp -r build/test build-cov/test
		ISTANBUL_REPORTERS=text-summary,cobertura,lcov $(BIN)/mocha --reporter mocha-istanbul --timeout 20s --debug build-cov/test
		mv lcov.info reports
		mv lcov-report reports
		rm -rf build-cov

coveralls: test coverage
		cat reports/lcov.info | ./node_modules/coveralls/bin/coveralls.js
		$(MAKE) clean

clean:
		rm -rf build-cov reports

.PHONY: test test-cov coverage