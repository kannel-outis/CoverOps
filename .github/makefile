ROOT_DIR := $(shell git rev-parse --show-toplevel)
SAMPLE_SCRIPT := $(ROOT_DIR)/.github/sample.sh

# Read pubspec.yaml from ROOT_DIR
DIRS := $(shell grep -A 100 "sub_modules:" $(ROOT_DIR)/pubspec.yaml | grep "path:" -A 100 | sed -n 's/ *- path: //p')
DIRS += .

define COMMANDS
	rm -f pubspec.lock && \
	dart pub get
endef

define TEST_CMD
	$(SAMPLE_SCRIPT)
endef

all: build_package
test: test_package
report: report_package

build_package:
	@for dir in $(DIRS); do \
		echo "Building $$dir..."; \
		(cd $(ROOT_DIR)/$$dir && $(COMMANDS)); \
	done

test_package:
	@for dir in $(DIRS); do \
		echo "Running tests in $$dir..."; \
		(cd $(ROOT_DIR)/$$dir && $(TEST_CMD)); \
	done

report_package:
	@echo "{" > $(shell pwd)/coverage_report.json; \
	first=1; \
	for dir in $(DIRS); do \
		report_path="$(ROOT_DIR)/$$dir/coverage/report.json"; \
		key="$$dir"; \
		if [ "$$key" = "." ]; then key="root"; fi; \
		key=$$(echo $$key | sed 's|^\./||'); \
		if [ -f "$$report_path" ]; then \
			content=$$(cat "$$report_path" | jq -c .); \
			if [ $$first -eq 0 ]; then echo "," >> $(shell pwd)/coverage_report.json; fi; \
			echo "  \"$$key\": $$content" >> $(shell pwd)/coverage_report.json; \
			first=0; \
		fi; \
	done; \
	echo "}" >> $(shell pwd)/coverage_report.json
