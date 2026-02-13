---
title: "Why I Stopped Stuffing Context into Prompts"
date: 2099-01-01
tags: [context-reduction, llm, tool-use, rag]
discord: "#context-reduction"
video: TBD
status: draft
---

# Why I Stopped Stuffing Context into Prompts

At some point, I realized I was spending more time managing prompts than solving problems.

Long prompts.
Carefully curated context.
Repeated explanations of the same structure.

The results weren't getting better—just more fragile.

So I stopped.

## The Problem with Long Context

Large context windows feel powerful, but they hide a cost:

- Token usage explodes
- Attention is diluted
- Models re-derive structure they should query

Long context is a blunt instrument.
It works—until it doesn't.

## What I Do Instead

Instead of asking a model to *remember*, I ask it to:

- inspect files
- query structured data
- operate on graphs
- call tools that already know the answers

This shifts work from reasoning to retrieval and execution.

That tradeoff is usually worth it.

## Reasoning Is Expensive

LLM "thinking" is not free.
It burns tokens, time, and attention.

If a problem can be reduced, indexed, or computed directly, I want that to happen *before* the model reasons.

Reasoning should be the last resort, not the first.

## Where This Leads

This way of working naturally leads to:

- recursive reduction
- graph-structured state
- tool-first architectures

Those ideas will show up repeatedly in upcoming posts and repos.

---

*This blog is intentionally comment-free.*

- Discussion: [Software Wrighter Lab Discord](https://discord.gg/INVITE_CODE) `#context-reduction`

**Prompt I'm curious about:** What's the largest prompt you've ever regretted writing?
