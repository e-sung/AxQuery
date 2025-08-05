.PHONY: test
test:
	set -o pipefail && xcodebuild test \
		-scheme AxQuery \
		-destination 'platform=iOS Simulator,name=iPhone 16' \
		-skipMacroValidation \

.PHONY: test-verbose
test-verbose:
	xcodebuild test \
		-scheme AxQuery \
		-destination 'platform=iOS Simulator,name=iPhone 16' \
		-skipMacroValidation

.PHONY: build
build:
	xcodebuild build \
		-scheme AxQuery \
		-destination 'platform=iOS Simulator,name=iPhone 16' \
		-skipMacroValidation

.PHONY: clean
clean:
	swift package clean
	rm -rf .build
	rm -rf ~/Library/Developer/Xcode/DerivedData/AxQuery-*
