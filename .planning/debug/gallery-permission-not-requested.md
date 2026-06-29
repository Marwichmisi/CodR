---
status: investigating
trigger: "Flutter app does not request gallery permission when user taps Save button in GeneratorScreen"
created: 2025-01-15T00:00:00Z
updated: 2025-01-15T00:02:00Z
---

## Current Focus

hypothesis: "CONFIRMED - Three issues: 1) AndroidManifest.xml missing gallery permissions, 2) Info.plist missing NSPhotoLibraryUsageDescription, 3) Screen bypasses PermissionService"
test: "Evidence confirms all three issues"
expecting: "Fix requires manifest/plist changes and optionally refactoring screen to use PermissionService"
next_action: "Return ROOT CAUSE FOUND diagnosis"

## Symptoms

expected: "When user taps Save button, app should request gallery permission before saving"
actual: "App does not request gallery permission; permission is not even visible in Android settings"
started: "Always broken - permissions never declared in manifest"

## Eliminated

(none yet)

## Evidence

- timestamp: 2025-01-15T00:01:00Z
  checked: "generator_screen.dart _saveToGallery() method (lines 206-218)"
  found: "Uses Permission.photos.request() directly, not PermissionService. Shows SnackBar if denied."
  implication: "Screen bypasses the PermissionService abstraction but the direct call should still work if manifest permissions exist"

- timestamp: 2025-01-15T00:01:00Z
  checked: "permission_service.dart hasGalleryPermission() and requestGalleryPermission()"
  found: "Properly handles both Permission.photos (iOS) and Permission.storage (Android) fallback"
  implication: "PermissionService is well-designed but not used by the save flow"

- timestamp: 2025-01-15T00:01:00Z
  checked: "AndroidManifest.xml"
  found: "Only android.permission.CAMERA is declared. No READ_MEDIA_IMAGES, READ_EXTERNAL_STORAGE, or WRITE_EXTERNAL_STORAGE."
  implication: "ROOT CAUSE: permission_handler cannot request permissions not declared in manifest"

- timestamp: 2025-01-15T00:01:00Z
  checked: "ios/Runner/Info.plist"
  found: "Only NSCameraUsageDescription is declared. Missing NSPhotoLibraryUsageDescription."
  implication: "iOS will also fail to show permission dialog for gallery access"

- timestamp: 2025-01-15T00:01:00Z
  checked: "generator_viewmodel.dart"
  found: "Has _permissionService injected but no save-related methods. Save logic is entirely in screen."
  implication: "Architecture mismatch - viewmodel was designed to handle permissions but screen handles save directly"

- timestamp: 2025-01-15T00:02:00Z
  checked: "app_router.dart"
  found: "GeneratorViewModel receives permissionService from router, but screen doesn't use it for save"
  implication: "PermissionService is available but ignored in the save flow"

## Resolution

root_cause: "AndroidManifest.xml does not declare READ_MEDIA_IMAGES or READ_EXTERNAL_STORAGE permissions. The permission_handler package can only request permissions declared in the manifest, so Permission.photos.request() silently fails. Additionally, iOS Info.plist is missing NSPhotoLibraryUsageDescription. Finally, the screen bypasses the PermissionService abstraction by calling Permission.photos.request() directly instead of using the properly implemented requestGalleryPermission() method."

fix: "1) Add READ_MEDIA_IMAGES and READ_EXTERNAL_STORAGE to AndroidManifest.xml 2) Add NSPhotoLibraryUsageDescription to Info.plist 3) Optionally refactor screen to use PermissionService for cross-platform consistency"

verification: "After fix, tapping Save should show permission dialog on both Android and iOS. Permission should be visible in app settings."

files_changed: []
