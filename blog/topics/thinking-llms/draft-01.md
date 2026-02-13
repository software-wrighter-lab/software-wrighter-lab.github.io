---
title: "Thinking Is Expensive: When LLM Reasoning Helps (and When It Hurts)"
date: YYYY-MM-DD
tags: [llm-reasoning, chain-of-thought, tool-use]
discord: "#llm-reasoning"
video: TBD
status: draft
---

# Thinking Is Expensive: When LLM Reasoning Helps (and When It Hurts)

LLMs that "think" are often more accurate.

They're also slower, more expensive, and sometimes confidently wrong in new ways.

So the question isn't:

> "Should models think?"

It's:

> "When is thinking actually worth it?"

## When Thinking Helps

Reasoning shines when:

- the problem is multi-step
- constraints interact
- the solution space is small but non-obvious

In these cases, showing intermediate steps improves correctness.

## When Thinking Hurts

Reasoning hurts when:

- the task is procedural
- the data is already structured
- the answer is retrievable

In those cases, thinking becomes theatrical overhead.

## My Rule of Thumb

I ask myself one question:

> Can this be answered by inspecting or transforming data directly?

If yes → tools first.
If no → reasoning, carefully.

## Why This Matters

As models get faster, it's tempting to let them reason all the time.

That's a mistake.

The future isn't thinking everywhere.
It's thinking *where it matters*.

---

*This blog is intentionally comment-free.*

- Discussion: [Software Wrighter Lab Discord](https://discord.gg/INVITE_CODE) `#llm-reasoning`

**What task do you explicitly *not* want a model to "think" about?**
