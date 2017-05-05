test:
	pod install --verbose --repo-update
	fastlane scan --scheme Emojize
lint:
	pod lib lint
