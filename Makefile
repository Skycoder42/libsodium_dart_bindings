# sources
LIB_FILES = $(shell find ./lib -type f -iname "*.dart")
SRC_FILES = $(shell find ./lib/src -type f -iname "*.dart")
API_UNIT_TEST_FILES = $(shell find ./test/unit/api -type f -iname "*.dart")
FFI_UNIT_TEST_FILES = $(shell find ./test/unit/ffi -type f -iname "*.dart")
JS_UNIT_TEST_FILES = $(shell find ./test/unit/js -type f -iname "*.dart")
UNIT_TEST_FILES = $(API_UNIT_TEST_FILES) $(FFI_UNIT_TEST_FILES) $(JS_UNIT_TEST_FILES)
INTEGRATION_TEST_FILES = $(shell find ./test/integration -type f -iname "*.dart")
TEST_FILES = $(UNIT_TEST_FILES) $(INTEGRATION_TEST_FILES)

MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))

#get 
.packages: pubspec.yaml
	dart pub get

get: .packages

get-clean:
	rm -rf .dart_tool
	rm -rf .packages
	$(MAKE) -f $(MAKEFILE) get

upgrade: .packages
	dart pub upgrade

# build
build: .packages
	dart run build_runner build

build-clean: upgrade
	dart run build_runner build --delete-conflicting-outputs
	
watch: .packages
	dart run build_runner watch
	
watch-clean: upgrade
	dart run build_runner watch --delete-conflicting-outputs

# analyze
analyze: .packages
	dart analyze --fatal-infos

# unit-tests
unit-tests-vm: get
	dart test test/unit/api test/unit/ffi

unit-tests-js: get
	dart test -p chrome test/unit/api test/unit/js

unit-tests: get
	$(MAKE) -f $(MAKEFILE) unit-tests-vm
	$(MAKE) -f $(MAKEFILE) unit-tests-js

# integration-tests
integration-tests-vm: get
	dart test test/integration/vm_test.dart

integration-tests-js: get
	dart test -p chrome test/integration/js_test.dart

integration-tests: get
	$(MAKE) -f $(MAKEFILE) integration-tests-vm
	$(MAKE) -f $(MAKEFILE) integration-tests-js

test: get
	$(MAKE) -f $(MAKEFILE) unit-tests
	$(MAKE) -f $(MAKEFILE) integration-tests

# coverage
coverage-vm: .packages
	dart test --coverage=coverage test/unit/api test/unit/ffi

coverage-js: .packages
	dart test -p chrome --coverage=coverage test/unit/api test/unit/js

coverage/.generated: .packages $(SRC_FILES) $(UNIT_TEST_FILES)
	@rm -rf coverage
	$(MAKE) -f $(MAKEFILE) coverage-vm
	$(MAKE) -f $(MAKEFILE) coverage-js
	touch coverage/.generated

coverage/lcov.info: coverage/.generated
	dart run coverage:format_coverage --lcov --check-ignore \
		--in coverage \
		--out coverage/lcov.info \
		--packages .packages \
		--report-on lib

coverage/lcov_cleaned.info: coverage/lcov.info
	lcov --remove coverage/lcov.info -output-file coverage/lcov_cleaned.info \
            '**/*.freezed.dart' \
            '**/*.ffi.dart' \
            '**/*.js.dart'

coverage/html/index.html: coverage/lcov_cleaned.info
	genhtml --no-function-coverage -o coverage/html coverage/lcov_cleaned.info

coverage: coverage/html/index.html

unit-tests-vm-coverage:
	@rm -rf coverage
	$(MAKE) -f $(MAKEFILE) coverage-vm
	touch coverage/.generated
	$(MAKE) -f $(MAKEFILE) coverage/lcov.info

unit-tests-js-coverage:
	@rm -rf coverage
	$(MAKE) -f $(MAKEFILE) coverage-js
	touch coverage/.generated
	$(MAKE) -f $(MAKEFILE) coverage/lcov.info

unit-tests-coverage: coverage/lcov.info

coverage-open: coverage/html/index.html
	xdg-open coverage/html/index.html || start coverage/html/index.html

#doc 
doc/api/index.html: .packages $(LIB_FILES)
	@rm -rf doc
	dartdoc --show-progress

doc: doc/api/index.html

doc-open: doc
	xdg-open doc/api/index.html || start doc/api/index.html

# publish
pre-publish:
	rm lib/src/.gitignore

post-publish:
	echo '# Generated dart files' > lib/src/.gitignore
	echo '*.freezed.dart' >> lib/src/.gitignore
	echo '*.g.dart' >> lib/src/.gitignore

publish-dry: .packages
	$(MAKE) -f $(MAKEFILE) pre-publish
	dart pub publish --dry-run
	$(MAKE) -f $(MAKEFILE) post-publish

publish: .packages
	$(MAKE) -f $(MAKEFILE) pre-publish
	dart pub publish --force
	$(MAKE) -f $(MAKEFILE) post-publish

# verify
verify:
	$(MAKE) -f $(MAKEFILE) build-clean
	$(MAKE) -f $(MAKEFILE) analyze
	$(MAKE) -f $(MAKEFILE) unit-tests-coverage
	$(MAKE) -f $(MAKEFILE) integration-tests
	$(MAKE) -f $(MAKEFILE) coverage-open
	$(MAKE) -f $(MAKEFILE) doc-open
	$(MAKE) -f $(MAKEFILE) publish-dry



.PHONY: build test coverage coverage-vm coverage-js doc