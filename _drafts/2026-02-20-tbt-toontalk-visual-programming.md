---
layout: post
title: "TBT: ToonTalk - Teaching Robots to Program"
date: 2026-02-20 00:00:00 -0800
categories: [tbt, visual-programming, vibe-coding]
tags: [tbt, toontalk, visual-programming, rust, webassembly, education, vibe-coding]
keywords: "ToonTalk, visual programming, programming by demonstration, Ken Kahn, Rust, WebAssembly, educational programming, tt-rs"
author: Software Wrighter
series: "Throwback Thursday"
series_part: 4
repo_url: "https://github.com/sw-fun/tt-rs"
---

<img src="/assets/images/posts/block-robot.png" class="post-marker" alt="">

I first discovered ToonTalk during the Windows XP era---probably around 2003 or 2004. It was unlike anything I'd seen: a programming environment disguised as a video game where you trained robots by showing them what to do. The concept stuck with me for two decades.

<div class="resource-box" markdown="1">

| Resource | Link |
|----------|------|
| **tt-rs Demo** | [Live Demo](https://sw-fun.github.io/tt-rs/) |
| **tt-rs Repo** | [tt-rs](https://github.com/sw-fun/tt-rs) |
| **Explainer** | Coming soon |

</div>

## What is ToonTalk?

ToonTalk is a visual programming environment created by [Ken Kahn](https://toontalk.com/English/kenkahn.htm) in 1995. The "Toon" stands for cartoon---every abstract programming concept is mapped to a concrete, animated metaphor:

| Concept | ToonTalk Metaphor |
|---------|-------------------|
| Variables | Boxes with numbered holes |
| Values | Numbers, text, images in boxes |
| Comparison | Scales that tip when values differ |
| Functions | Robots that watch and learn |
| Message passing | Birds that carry items to nests |
| Garbage collection | Trucks that haul away unused items |

The design was influenced by games like *The Legend of Zelda* and *Robot Odyssey*---the kind of games that made you think while you played.

## Programming by Demonstration

The core idea is radical: you don't write code, you *show* a robot what to do.

1. Create a robot and put it in "training mode"
2. Perform actions while the robot watches (move items, compare values, etc.)
3. The robot records your actions as a program
4. Give the robot a box matching the training pattern---it executes the learned behavior

This is programming by demonstration. The robot generalizes from your example, matching patterns and applying transformations. It's the same conceptual model as teaching a child: "Watch what I do, then you try."

## Three Generations

ToonTalk has existed in three forms:

| Version | Era | Technology |
|---------|-----|------------|
| **Original ToonTalk** | 1995-2009 | C++, 3D desktop application |
| **ToonTalk Reborn** | 2014-2017 | JavaScript/jQuery web app |
| **tt-rs** | 2025-2026 | Rust/WebAssembly/Yew |

The original was a full 3D world---cities, houses, helicopters, even bombs for debugging. Ken Kahn later created [ToonTalk Reborn](https://github.com/ToonTalk/ToonTalk), a simplified JavaScript version that runs in browsers.

## Why I Built tt-rs

When I rediscovered ToonTalk Reborn a few years ago, I wanted to experiment with the concepts myself. But diving into a large jQuery codebase wasn't appealing. So I did what any reasonable person would do: I vibe coded my own version in Rust.

**tt-rs** is a modern reimplementation using:

- **Rust** for core logic
- **WebAssembly** for browser execution
- **Yew** for reactive UI
- **SVG/CSS** for graphics and animations

It's not a port---it's a fresh implementation inspired by the same ideas. Building it myself lets me understand the concepts deeply and experiment with variations.

## Current Features

The [live demo](https://sw-fun.github.io/tt-rs/) includes:

**Widgets:**
- **Numbers**: Rational arithmetic with +, -, *, / operators
- **Boxes**: Configurable containers with 0-9 holes
- **Text**: Basic text display
- **Scales**: Visual comparison that tips when values differ
- **Robot**: Training mode, action recording, basic execution
- **Bird/Nest**: Message passing (in progress)

**Tools:**
- **Wand**: Copy any widget
- **Vacuum**: Remove widgets

**Features:**
- Drag-and-drop interaction
- Contextual help panel with tutorials
- Puzzle system with animated "Show Me" demos
- User levels (tt1 basics, tt2 messaging)

## What's Next

The immediate priorities for tt-rs:

1. **Bird/Nest messaging** - Complete the actor-model message passing
2. **Pattern matching with erasure** - Generalize patterns by removing detail
3. **Persistence** - Save and load workspaces

Long term, I'd like to add the 3D elements from the original---the cities, the houses, the helicopter view. But that's a much larger project.

## The Enduring Appeal

What makes ToonTalk fascinating isn't just the visual metaphors---it's the *computational model*. Under the hood, ToonTalk implements concurrent constraint logic programming. The robots are essentially guarded Horn clauses. The birds and nests implement the actor model.

Heavy concepts, but you don't need to know any of that to use it. You just train robots by example. The abstraction is complete.

That's why it stuck with me for twenty years. Good abstractions are rare. When you find one, it's worth understanding deeply.

<div class="references-section" markdown="1">

## References

| Resource | Link |
|----------|------|
| **ToonTalk Website** | [toontalk.com](https://www.toontalk.com/) |
| **ToonTalk on Wikipedia** | [Wikipedia](https://en.wikipedia.org/wiki/ToonTalk) |
| **ToonTalk Reborn (JS)** | [github.com/ToonTalk/ToonTalk](https://github.com/ToonTalk/ToonTalk) |
| **ToonTalk Reborn Demo** | [toontalk.github.io/ToonTalk](https://toontalk.github.io/ToonTalk/) |
| **ToonTalk Reborn Wiki** | [Wiki](https://github.com/ToonTalk/ToonTalk/wiki) |
| **Ken Kahn's Page** | [Ken Kahn](https://toontalk.com/English/kenkahn.htm) |
| **Original Paper (1995)** | [ERIC - ToonTalk: An Animated Programming Environment](https://eric.ed.gov/?id=ED392435) |
| **Ken Kahn's Research** | [Academia.edu](https://www.academia.edu/2795458/ToonTalk_and_Logo) |

</div>

---

*Some ideas are worth rediscovering. ToonTalk is one of them.*

