# Small CLs (Google Engineering Practices, code review guide)
Library file: 05-code-review-process/google-small-cls.md (text: _text/google-small-cls.txt). Read by the conductor on 2026-10-21.

**Question:** how big should one reviewed change be?
**Findings:** the right size is one self-contained change that includes its tests and leaves the system working; small changes are reviewed faster and more thoroughly, introduce fewer bugs, merge more easily, and roll back more simply. Reviewers may reject a change purely for being too large.
**Limits:** this is review guidance from Google, a judgement call, not a measured law; the page itself says there are no hard rules.
**Verified quote:** "100 lines is usually a reasonable size for a CL, and 1000 lines is usually too large, but it's up to the judgment of your reviewer."
**Lesson for TrackFlow:** worker jobs must be small. Wave A job TF-G3B changed about 1,260 lines of one file (728 added, 533 removed); that is the "too large" end and was hard to review. From now on each job targets roughly 100-300 changed lines plus its tests, and the data-layer wave (Wave B) is split into small steps that can each be merged and rolled back alone.
