# The evolution of Facebook's iOS app architecture (Engineering at Meta, 2023)
Library file: 08-app-architecture-di/meta-2023-facebook-ios-app-architecture.html (text: _text/meta-2023-facebook-ios-app-architecture.txt). First ~3.5 KB of the text read by the conductor on 2026-10-21; the rest (build system, code generation, modules) is NOT yet read.

**Question:** how did a very large mobile codebase end up organised the way it is?
**Findings (from the part read):** the codebase grew over ten years and was never designed up front; a News Feed reliability problem came from mutable data models plus bidirectional data flow; moving to a declarative UI with a one-way data flow made behaviour easier to reason about and gave a large speed-up.
**Limits:** a company blog post about one very large app with thousands of engineers; it describes what they did, not that it suits a one-person app. Do not copy their scale tooling.
**Verified quote:** "FBiOS was never intentionally architected this way."
**Verified quote:** "Objects in Core Data are mutable, and that did not lend itself well to News Feed’s multithreaded architecture."
**Lesson for TrackFlow:** keep HabitItem immutable and let data flow one way (repository -> view model -> view). Grow the structure in small steps instead of a big-bang redesign.
