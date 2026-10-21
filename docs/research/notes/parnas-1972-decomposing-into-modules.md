# On the Criteria To Be Used in Decomposing Systems into Modules (Parnas, 1972)
Library file: 01-modularity-and-structure/parnas-1972-criteria-for-decomposing-into-modules.pdf (text: _text/parnas-1972-criteria-for-decomposing-into-modules.txt). Key passages read by the conductor on 2026-10-21; paper not read end to end.

**Question:** by what rule should a system be split into modules?
**Findings:** the second decomposition (by information hiding) makes each module know one design decision that it hides from all others, and its modules no longer correspond to the steps of the processing.
**Limits:** 1972 paper with a small example (a text-processing program); the principle is old and widely taught, the example does not model a modern app.
**Verified quote:** "Its interface or definition was chosen to reveal as little as possible about its inner workings."
**Lesson for TrackFlow:** split a file when it holds more than one decision that can change independently (for example: how habits are stored, how a streak is defined, how a cell is drawn), not because it passed a line count. The library checklist (section B) says the same about size: a thermometer, not the disease.
