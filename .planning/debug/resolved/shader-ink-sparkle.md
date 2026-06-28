---
status: resolved
trigger: "navigation_test.dart: tapping Generator tab shows Generator screen - erreur asset shaders/ink_sparkle.frag (problème de version de runtime shader Flutter)"
created: 2026-06-28T00:00:00Z
updated: 2026-06-28T00:00:00Z
---

## Current Focus

hypothesis: "The shader error is caused by stale build artifacts - the ink_sparkle.frag shader in the build directory has incompatible or corrupted runtime stage data"
test: "Run flutter clean to remove stale artifacts, then run tests again"
expecting: "Tests should pass after clean build"
next_action: "Update UAT.md to reflect the resolution"

## Symptoms

expected: All 28 tests pass including navigation_test.dart
actual: 27/28 tests pass, 1 test fails with shader error
errors: "erreur asset shaders/ink_sparkle.frag"
reproduction: Run navigation_test.dart - tapping Generator tab shows Generator screen test
started: Discovered during UAT for phase 01-foundation-navigation

## Eliminated

- hypothesis: "Flutter version incompatibility"
  evidence: Flutter 3.44.4 (stable) installed, all tests pass after flutter clean, same version works fine
  timestamp: 2026-06-28T00:00:00Z

- hypothesis: "Code bug in navigation_test.dart"
  evidence: Test logic is correct, all tests pass after flutter clean
  timestamp: 2026-06-28T00:00:00Z

- hypothesis: "Missing shader file"
  evidence: ink_sparkle.frag exists in build directory after flutter clean
  timestamp: 2026-06-28T00:00:00Z

## Evidence

- timestamp: 2026-06-28T00:00:00Z
  checked: Flutter version and test execution
  found: Flutter 3.44.4 (stable) installed, all 28 tests pass when run individually
  implication: The issue is not a consistent Flutter version incompatibility

- timestamp: 2026-06-28T00:00:00Z
  checked: Build directory for shader files
  found: ink_sparkle.frag exists in build/unit_test_assets/shaders/ and build/app/intermediates/
  implication: Shader files are present in build artifacts

- timestamp: 2026-06-28T00:00:00Z
  checked: Web search for similar issues
  found: Known Flutter issues #187725 (race condition with concurrent test runs), #143806 (Vulkan backend mismatch), and blog post about stale artifacts after Flutter update
  implication: This is a known Flutter issue with multiple potential causes

- timestamp: 2026-06-28T00:00:00Z
  checked: Flutter clean and retest
  found: After running flutter clean, all 28 tests pass without errors
  implication: The issue was caused by stale build artifacts, not a code or version problem

## Resolution

root_cause: "Stale shader build artifacts - the ink_sparkle.frag shader in the build directory had incompatible or corrupted runtime stage data. This is a known Flutter issue that occurs when: (1) Flutter version is updated and shader format changes, (2) concurrent test runs cause race conditions on shared build assets, or (3) build artifacts become corrupted."
fix: "Run 'flutter clean' to remove stale build artifacts, then run tests again. All 28 tests pass after clean build."
verification: "Ran flutter clean followed by flutter test - all 28 tests passed"
files_changed: []