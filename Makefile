.PHONY: get gen clean upgrade format

# Get dependencies
get:
	flutter pub get

# Generate code
gen:
	dart run build_runner build --delete-conflicting-outputs

# Watch for changes and generate code
gen-watch:
	dart run build_runner watch --delete-conflicting-outputs

# Clean the project
clean:
	flutter clean
	flutter pub get

# Upgrade dependencies
upgrade:
	flutter pub upgrade

# Format code
format:
	dart format lib/