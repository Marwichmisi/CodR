# GSD Debug Knowledge Base

Resolved debug sessions. Used by `gsd-debugger` to surface known-pattern hypotheses at the start of new investigations.

---

## shader-ink-sparkle — Stale shader build artifact causing test failure
- **Date:** 2026-06-28
- **Error patterns:** shaders/ink_sparkle.frag, navigation_test, Material 3, InkSparkle
- **Root cause:** Stale ink_sparkle.frag shader in build directory with incompatible runtime stage data
- **Fix:** Run flutter clean to remove stale build artifacts, then run tests again
- **Files changed:** None (build artifact cleanup only)
---