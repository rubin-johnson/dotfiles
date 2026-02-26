---
name: no-skip-tests
enabled: true
event: file
conditions:
  - field: new_text
    operator: regex_match
    pattern: (skip|xfail|\.skip|pending|xit\(|xdescribe\(|xcontext\(|pytest\.mark\.skip|@unittest\.skip|@pytest\.mark\.xfail)
---

**Do not skip or weaken tests.**

You are adding a test skip/disable marker. Per quality standards:
- Never weaken or delete a failing test
- Never change test expectations without explaining why the old one was wrong
- If a test is failing, fix the code — not the test

If you believe this skip is justified, explain why to the user before proceeding.
