# Roadmap: QR Code Scanner & Generator

## Overview

Build a Flutter mobile app that scans QR codes via camera and generates QR codes from text/URLs. The journey starts with project foundation and navigation, moves to the riskiest integration (camera scanner), adds content display and QR generation, then completes with history persistence. Each phase delivers a verifiable capability, with Flutter skills applied throughout for architecture, testing, and responsive layout.

## Phases

- [x] **Phase 1: Foundation & Navigation** - Project scaffolded with MVVM, Material 3 theme, navigation, and SQLite storage
- [x] **Phase 2: Camera Scanner** - QR scanning via camera with permissions, overlay, torch, and lifecycle management (completed 2026-06-28)
- [ ] **Phase 3: Scan Results & Content Display** - Scanned content shown with URL detection, action buttons, and error handling
- [ ] **Phase 4: QR Generation** - Generate QR codes from text input with save, share, and copy capabilities
- [ ] **Phase 5: History & Data Persistence** - Scan/generation history stored in SQLite with search, filter, and delete

## Phase Details

### Phase 1: Foundation & Navigation

**Goal**: Project is scaffolded with MVVM architecture, Material 3 theme, navigation between screens, and SQLite storage foundation ready
**Depends on**: Nothing (first phase)
**Requirements**: INFRA-01, INFRA-02, INFRA-03, INFRA-04, INFRA-05, UI-01, UI-05, QUAL-03
**Success Criteria** (what must be TRUE):

  1. Flutter project runs with MVVM architecture structure (lib/models, lib/viewmodels, lib/services, lib/screens)
  2. Material 3 theme is configured with consistent colors and typography across the app
  3. Bottom navigation switches between Scanner, Generator, and History screens
  4. Data models (ScanRecord, GenerationRecord) are defined and SQLite database initializes correctly
  5. Layout adapts responsively to different screen sizes (phone and tablet)

**Plans**: 4 plans

Plans:
**Wave 1**

- [x] 01-01: Project setup with MVVM architecture and Material 3 theme (flutter-apply-architecture-best-practices, flutter-setup-localization)

**Wave 2** *(blocked on Wave 1 completion)*

- [x] 01-02: Navigation shell with bottom nav and data models (flutter-setup-declarative-routing)

**Wave 3** *(blocked on Wave 2 completion)*

- [x] 01-03: SQLite storage service and responsive layout foundation (flutter-build-responsive-layout)

**Wave 4** *(gap closure)*

- [x] 01-04: Clean stale shader artifacts to fix test failure

### Phase 2: Camera Scanner

**Goal**: Users can scan QR codes via camera with real-time detection, proper permissions, and stable camera lifecycle
**Depends on**: Phase 1
**Requirements**: SCAN-01, SCAN-02, SCAN-03, SCAN-04, SCAN-05, SCAN-06, UI-02
**Success Criteria** (what must be TRUE):

  1. Camera opens with preview and a visual scan overlay guide is displayed
  2. QR codes are detected in real-time and content is captured accurately
  3. Torch toggle works to illuminate dark environments
  4. Camera lifecycle is handled correctly — no black screen when returning from other screens
  5. Duplicate scan detections are prevented (single QR triggers one result, not 5-20)

**Plans**: 3/3 plans complete

Plans:

- [x] 02-01-PLAN.md
- [x] 02-02-PLAN.md
- [x] 02-03-PLAN.md

- [x] 02-01: Intégration caméra, permissions et overlay (mobile_scanner, permission_handler)
- [x] 02-02: Contrôle de la torche et cycle de vie (WidgetsBindingObserver)
- [x] 02-03: Anti-rebond/dédoublonnage et SnackBar (HapticFeedback, SnackBar)

### Phase 3: Scan Results & Content Display

**Goal**: Scanned content is displayed with actionable buttons, URL detection works, and error states are handled gracefully
**Depends on**: Phase 2
**Requirements**: SCAN-07, SCAN-08, QUAL-01, QUAL-04
**Success Criteria** (what must be TRUE):

  1. URLs in scanned content are detected and user can tap to open in browser
  2. Content display shows copy, share, and open (if URL) action buttons
  3. Unit tests pass for ScannerViewModel and ResultViewModel
  4. Error states (camera permission denied, scan failure, empty result) show appropriate UI

**Plans**: 2 plans

Plans:

- [ ] 03-01: URL detection and content display with action buttons (share_plus, clipboard)
- [ ] 03-02: Error handling, loading states, and unit tests for ViewModels

### Phase 4: QR Generation

**Goal**: Users can generate QR codes from text input with character limit, and save/share/copy the result
**Depends on**: Phase 1
**Requirements**: GEN-01, GEN-02, GEN-03, GEN-04, GEN-05, GEN-06, GEN-07, UI-03, QUAL-02
**Success Criteria** (what must be TRUE):

  1. Text input generates a QR code preview in real-time as user types
  2. Character counter enforces 250 character maximum with visual feedback
  3. Generated QR can be saved to device gallery as image
  4. Generated QR can be shared via native share sheet
  5. Content can be copied to clipboard and widget tests pass for generator screen

**Plans**: 3 plans

Plans:

- [ ] 04-01: QR generation with character limit and URL detection (qr_flutter)
- [ ] 04-02: Save to gallery and share functionality (image_gallery_saver, share_plus, path_provider)
- [ ] 04-03: Clipboard copy, widget tests, and generator screen UI polish (flutter-add-widget-test)

### Phase 5: History & Data Persistence

**Goal**: All scans and generations are persisted in SQLite, displayed in a searchable list, and manageable by the user
**Depends on**: Phase 1, Phase 2, Phase 4
**Requirements**: HIST-01, HIST-02, HIST-03, HIST-04, UI-04
**Success Criteria** (what must be TRUE):

  1. Scans and generations are automatically saved to SQLite history
  2. History screen displays recent entries with timestamp and content preview
  3. History can be searched and filtered by text content
  4. Entries can be deleted from history with confirmation

**Plans**: 2 plans

Plans:

- [ ] 05-01: SQLite history storage integration and history list view
- [ ] 05-02: Search/filter functionality and delete with confirmation

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Foundation & Navigation | 4/4 | ✓ Complete | 2026-06-28 |
| 2. Camera Scanner | 3/3 | Complete    | 2026-06-28 |
| 3. Scan Results & Content Display | 0/2 | Not started | - |
| 4. QR Generation | 0/3 | Not started | - |
| 5. History & Data Persistence | 0/2 | Not started | - |
