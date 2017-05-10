test:
	pod install --verbose --repo-update
	fastlane scan --scheme Ansi
lint:
	pod lib lint
