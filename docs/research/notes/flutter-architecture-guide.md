# Guide to app architecture (Flutter team, Google)
Library file: 08-app-architecture-di/flutter-architecture-guide.md (text: _text/flutter-architecture-guide.txt). Read in full by the conductor on 2026-10-21 (first ~9 KB of 17 KB read as markdown, key sections checked in the text file).

**Question:** how should a Flutter app be layered?
**Findings:** two layers, UI and data. Components: Views, View models, Repositories, Services. Every feature = one view + one view model + one or more repositories + zero or more services. An optional domain layer (use cases) sits between UI and data for complex logic. Views contain no business logic; view models turn repository data into UI state and expose commands.
**Limits:** official guidance for typical apps; it says itself the recommendations are guidelines, not rules. Written for apps with network services; TrackFlow has no network.
**Verified quote:** "Views and view models should have a one-to-one relationship."
**Verified quote:** "Views are the primary method of rendering UI, and shouldn't contain any business logic."
**Lesson for TrackFlow:** the header, matrix and heatmap widgets compute statistics inside the widget (executive_summary_header.dart, multi_day_matrix_view.dart, yearly_heatmap_canvas.dart). That logic belongs in a view model / domain function. See docs/engineering/FILE-ORGANIZATION.md.
