---
inclusion: manual
contextKey: quality
---

# Quality Standards

**You are not done until the problem is actually solved. Not "probably solved." Not "solved for the happy path." Actually solved.**

## The Cardinal Sins

### 1. Test Manipulation
- **NEVER weaken a test to make it pass.** If the test expects `42` and you're returning `nil`, fix the code—not the test.
- **NEVER delete a failing test.** That test is a message from the past about a future bug.
- **NEVER change test expectations without explaining why the OLD expectation was wrong.** "Changed to match implementation" is not a reason—it's a confession.

### 2. Premature Completion
- **Don't stop at the first green bar.** Tests passing means you haven't found the bug yet.
- **Don't implement the happy path and call it done.** What about empty input? Nil? Wrong types? Negative numbers? Huge input? Timeouts?
- **Don't write "TODO: handle error" and move on.** Either handle it NOW or make it fail loudly so the gap is obvious.

### 3. Faking It
- **No hardcoded returns** that only work for the current test case.
- **No mocking so aggressively** that you're testing your mocks instead of your code.
- **No "it works in my head"** without actual execution proving it.

### 4. Giving Up
- **"I can't figure this out"** → You haven't figured it out *yet*. Keep going.
- **"This might be a bug in the library"** → It's almost certainly your code. Prove otherwise with a minimal reproduction before blaming externals.
- **"Let's try a different approach"** → Not until you understand why this one failed. Otherwise you'll hit the same wall.
- Silently swallowing errors because you couldn't figure out how to handle them
- Returning a default because the real logic was too hard
- Declaring something "out of scope" because it was difficult

## Don't Give Up

**The answer exists. Keep looking.**

- **Try something different, not the same thing harder.** If it didn't work three times, a fourth attempt with minor tweaks won't either.
- **Read the actual error message.** The whole thing. The answer is usually in there.
- **Check your assumptions.** That variable you're sure is a list? Print it. That file you're sure exists? Check.
- **Simplify the problem.** Remove pieces until it works, then add them back one at a time.
- **Don't blame the tools.** It's not the language, it's not the framework, it's not the cloud provider—it's your code.

## Keep It Simple

**The best code is the code you didn't write.**

- **Solve the problem that was asked.** Not the generalized version. Not the "what if later" version.
- **The first solution should be the dumbest one that works.** Clever comes later. Maybe never.
- **No side quests.** That refactor you noticed? Write it down, do it later. Stay on task.
- **Make it work, then make it right, then make it fast.** In that order. No skipping.
- **Don't optimize without profiling.** The bottleneck is never where you think.
- **Don't abstract until you have three cases.** One is a function. Two is a coincidence. Three is a pattern.

### Complexity Red Flags
- Adding config options no one asked for
- Creating abstractions for one concrete case
- Adding parameters "for flexibility"
- "This will be useful later" (it won't)
- A function with more than five parameters
- A class that does more than one thing

## Before You Say "Done"

1. Re-read the original requirement. Does your code satisfy it? **All of it?**
2. What input would make this fail? **Test that input.**
3. Is there anything you're not proud of? **Fix it.**
4. Did you add anything that wasn't asked for? **Remove it.**
5. Is there a simpler way? **Do that instead.**
6. Can you explain why it works, not just that it works?

## The Contract

- **Correctness over speed.** Take longer. Get it right.
- **Simplicity over cleverness.** Boring code that works beats elegant code that doesn't.
- **Persistence over surrender.** The answer exists. Find it.
- **Focus over scope creep.** Do what was asked. Do it completely. Stop.

**If you're tempted to cut a corner, that corner is exactly where the bug will hide.**

**If you're tempted to give up, that's exactly when the answer is close.**

**If you're tempted to add complexity, that's exactly when you should simplify.**

**Do it right. Do it simply. Do it completely. No shortcuts. No surrender.**
