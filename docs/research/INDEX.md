# Research index for TrackFlow
Universal library: see GOLDEN-LINK.md (read-only, never edited from here). Checklist copy to tick with proof: ../engineering-checklist.md.
"Read" = the conductor read it and wrote a note with a verified quote. "Next" = chosen as relevant, not yet read.

| Document (library path) | Why it matters here | Status |
|---|---|---|
| 08-app-architecture-di/flutter-architecture-guide.md | official layering: views, view models, repositories, services | Read: notes/flutter-architecture-guide.md |
| 05-code-review-process/google-small-cls.md | size of one change; worker job sizing | Read: notes/google-small-cls.md |
| 08-app-architecture-di/meta-2023-facebook-ios-app-architecture.html | immutable models, one-way data flow, grow structure incrementally | Partly read: notes/meta-2023-facebook-ios-architecture.md |
| 01-modularity-and-structure/parnas-1972-criteria-for-decomposing-into-modules.pdf | split by hidden decision, not by step or line count | Key passages read: notes/parnas-1972-decomposing-into-modules.md |
| 07-monolith-vs-microservices/shopify-packwerk-enforcing-modularity.html | enforce boundaries with a tool (our architecture test) | Next |
| 08-app-architecture-di/flutter-case-study-dependency-injection.md, flutter-case-study-testing.md, flutter-architecture-recommendations.md | how to inject a repository and test view models with fakes | Next |
| 08-app-architecture-di/android-modularization-guide.html, now-in-android-modularization-journey.md | feature-first modules and when NOT to split | Next |
| 08-app-architecture-di/cockburn-hexagonal-architecture.html, martin-2012-clean-architecture.html | domain independent of storage and UI | Next |
| 04-testing/swe-at-google-ch11..14 | test sizes, doubles, flakiness | Next |
| 18-delivery-and-engineering-practice/swe-at-google-ch15-deprecation.html, trunk-based-development.html, swe-at-google-ch23/24 | deprecation, CI, staged delivery | Next |
| 03-size-and-metrics/ (El Emam 1999, Chowdhury 2022) | file size as a thermometer | Next, to check the checklist claim against the papers |

Gaps in the library for this project: it has no Apple engineering document; its Amazon material is about distributed systems and reliability (Dynamo, Builders Library), not about how to lay out a mobile app's files.
