---
title: AI use policy
---

# AI Use Policy

**During a capstone, AI reads code with you. It doesn't write code for you.**

That one line is the whole policy. The table below is just that rule applied to specific
things you'll want to do.

This is not about catching anyone out. It's about what you'll be able to do on your own in
a job interview and in your first weeks at TQL — and about a harder problem: **you cannot
review code you never understood.** Reviewing AI output is the single most important skill
in this course's AI thread, and it only works if you can already write the thing yourself.
Every hour you spend building a feature by hand is what makes you dangerous with an
assistant later.

## The test

When you're about to accept something from an assistant, ask:

> **Did I already know what I wanted to write?**

If yes, the assistant saved you keystrokes. That's fine.
If no, the assistant made the decision. During a capstone, that's not fine — that's the
decision you're here to practice making.

## What's allowed when

| What you want to do | During a capstone | After the capstone |
|---|---|---|
| Ask AI to explain code you're reading | ✅ | ✅ |
| Ask AI to explain an error message or stack trace | ✅ | ✅ |
| Look up syntax, an API, or a library's docs | ✅ | ✅ |
| Describe a bug's symptoms and ask where to look | ✅ | ✅ |
| Ask AI to review code **you wrote** and critique it | ✅ | ✅ |
| Inline autocomplete finishing a line you'd already decided on | ✅ | ✅ |
| Inline autocomplete writing a block you hadn't thought through | ❌ | ✅ *(audited)* |
| Ask Chat to generate a component, controller, or form | ❌ | ✅ *(audited)* |
| Ask AI to design your data model or choose your approach | ❌ | ✅ *(audited)* |
| Agent mode / autonomous multi-file changes | ❌ | ✅ *(post-capstone block)* |

**Not yet ≠ never.** Everything in the ❌ column opens up as soon as the capstone is
done — that's what Lesson 16 and the post-capstone team block are for. The sequencing is
deliberate: you learn to *judge* AI output before you let it *generate*, and you learn to
build a thing by hand before you let something else build it for you.

## Using it well on the allowed side

The allowed column isn't a consolation prize — used properly it's most of the value.
Prompts that work:

- *"Explain what this `useEffect` dependency array is doing and when it re-runs."*
- *"I'm getting `Cannot read properties of undefined (reading 'name')` on this page. What
  are the likely causes?"* — then go check them yourself.
- *"Here's my controller. What's wrong with it?"* — the review habit from **API Lesson 7**.
- *"What's the difference between `FindAsync` and `SingleOrDefaultAsync`?"*

Prompts to save for later:

- *"Write me a Vendors feature folder."*
- *"Build the request detail page."*

!!! warning "Always verify — the assistant is confidently wrong sometimes"

    This applies on both sides of the line. An explanation is a claim, not a fact. If it
    tells you why a bug happens, go confirm it in the running app, in Insomnia, or in the
    browser console before you act on it. A confident, plausible, wrong diagnosis is the
    most expensive thing an assistant produces.

## The AI thread, end to end

AI isn't one lesson in this course. It's five touchpoints teaching **four different skills**, in
a deliberate order — and notice that none of the four verbs is *"let it write the code."*

| Where | The skill | What you actually do | Verified by |
|---|---|---|---|
| **API Lesson 7** | **Judge** | Point Copilot at a controller **you wrote**, and triage its review — accept, reject, ignore, with a reason for each | Insomnia, on anything you accepted |
| **HTML/CSS pass** | *(none required)* | Fundamentals are hand-built. Copilot appears only as optional stretch work — see the note below | — |
| **React Lesson 16** | **Generate** | Autocomplete → Chat → agent mode, plus the repo conventions file that keeps output on-convention | The browser and DevTools |
| **React Lessons 17–18** | **Specify** | Write tests by hand first — then watch what a *generated* suite does to code that's already broken | The terminal: red, then green |
| **Team block Lesson 3** | **Supervise** | Scope a ticket, isolate an agent in its own worktree, audit the diff twice, and own every line of it in review | The diff, the app, a teammate's review |
| **Team block Lesson 4** | **Comprehend** | Use AI to read code you didn't write — and treat its diagnosis as a hypothesis, never a finding | The running app, Insomnia, SSMS |

**The order is the argument.** You judge output before you generate any, because triaging a review
of your own code is the lowest-risk place to discover that a confident answer can be wrong. You
generate only after two front ends built by hand, because the conventions you're auditing against
have to be ones you already hold. You supervise an agent only once you can generate and audit
alone. And the last skill — using AI to comprehend unfamiliar code — is deliberately last, because
it's the one with the most expensive failure mode and the least visible one: an explanation that
sounds right, names a real file, and is entirely wrong.

!!! note "Why the HTML/CSS pass has no required AI lesson"

    It's the one pass where generation would undercut the point. You're learning the box model and
    flexbox by writing them, and an assistant that produces working layout removes exactly the
    struggle that teaches it. Copilot returns in the React pass, on the same markup, once you can
    tell good output from output that merely renders.

Keep the [Copilot quick-start](copilot-quickstart.md) open — it has the setup steps, the
three surfaces, and the conventions watch-list of things Copilot will suggest that are
wrong for this codebase.

## If you're not sure

Ask. "Is it okay if I use AI for X?" is always a fine question, and asking it is a better
signal about you than quietly guessing either way.
