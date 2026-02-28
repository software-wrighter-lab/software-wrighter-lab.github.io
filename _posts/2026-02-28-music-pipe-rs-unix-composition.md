---
layout: post
title: "music-pipe-rs: Unix Philosophy Meets Generative Composition"
date: 2026-02-28 00:15:00 -0800
categories: [vibe-coding, rust, music, cli]
tags: [music-pipe-rs, rust, midi, generative-music, unix-philosophy, cli, algorithmic-composition]
keywords: "music-pipe-rs, generative music, MIDI composition, Unix pipes, Rust, algorithmic composition, command line, JSONL, deterministic, Euclidean rhythms, scales, humanize"
author: Software Wrighter
abstract: "A Unix-style pipeline engine for generative MIDI composition. Chain small, composable command-line tools to create melodies, rhythms, and full arrangements—all from the terminal."
repo_url: "https://github.com/softwarewrighter/music-pipe-rs"
demo_url: "https://softwarewrighter.github.io/music-pipe-rs/"
---

<img src="/assets/images/posts/block-music-sheet.png" class="post-marker" alt="">

What if you could compose music the same way you write shell scripts? Pipe commands together, each doing one thing well. That's exactly what music-pipe-rs does. Unix philosophy meets generative composition.

<div class="resource-box" markdown="1">

| Resource | Link |
|----------|------|
| **Live Demo** | [music-pipe-rs Samples](https://softwarewrighter.github.io/music-pipe-rs/) |
| **Source** | [GitHub](https://github.com/softwarewrighter/music-pipe-rs) |

</div>

## The Unix Way

music-pipe-rs is a collection of small command-line tools for algorithmic MIDI composition. Each reads stdin, transforms the stream, and writes to stdout. Chain them with pipes:

```bash
seed 12345 | motif --notes 16 --bpm 120 \
  | scale --root C --mode major \
  | humanize \
  | to-midi --out melody.mid
```

**Seed** controls randomness. **Motif** generates melodies. **Scale** constrains to key. **Humanize** adds feel. **To-midi** outputs the file. All deterministic—same seed, same output, every time.

## Available Stages

| Stage | Description |
|-------|-------------|
| `seed` | Set random seed for reproducibility |
| `motif` | Generate melodic patterns |
| `seq` | Input explicit note sequences |
| `euclid` | Generate Euclidean rhythms |
| `transpose` | Shift notes by semitones |
| `scale` | Constrain to musical scale |
| `humanize` | Add timing and velocity variation |
| `viz` | Show sparkline visualization |
| `to-midi` | Convert to .mid file |

## JSONL Event Stream

Stages communicate via JSONL (JSON Lines). Each event is a single JSON object:

```json
{"type":"Seed","seed":12345}
{"type":"Tempo","t":0,"bpm":120}
{"type":"NoteOn","t":0,"ch":0,"key":60,"vel":96}
{"type":"NoteOff","t":240,"ch":0,"key":60}
```

This means you can use standard Unix tools to inspect and manipulate the stream:

```bash
# See raw events
seed 12345 | motif --notes 8 | head

# Filter specific events
seed 12345 | motif | grep NoteOn

# Pretty-print with jq
seed 12345 | motif | jq .
```

## Euclidean Rhythms

The `euclid` stage generates mathematically spaced rhythms:

```bash
seed | {
  euclid --steps 16 --pulses 4 --note 36 --ch 9 --bpm 120;
  euclid --steps 16 --pulses 2 --note 38 --ch 9 --rotation 4;
  euclid --steps 16 --pulses 8 --note 42 --ch 9 --vel 60;
} | humanize | to-midi --out drums.mid
```

Euclidean rhythms distribute pulses as evenly as possible across steps—the mathematical foundation of many traditional rhythms worldwide.

## Full Arrangements

Build multi-instrument pieces by generating each part separately and combining:

```bash
SEED=42

# Melody
seed $SEED | motif --base 72 --notes 16 --ch 0 > /tmp/mel.jsonl

# Bass
seed $SEED | motif --base 48 --notes 16 --ch 1 > /tmp/bass.jsonl

# Drums
seed $SEED | euclid --steps 16 --pulses 4 --note 36 --ch 9 > /tmp/drums.jsonl

# Combine and export
cat /tmp/mel.jsonl /tmp/bass.jsonl /tmp/drums.jsonl \
  | scale --root C --mode minor \
  | humanize \
  | to-midi --out arrangement.mid
```

## Web Demo

The project includes a [web demo](https://softwarewrighter.github.io/music-pipe-rs/) with pre-built examples:

- **Bach Toccata (Full Organ)** - Multi-voice church organ with octave doubling
- **Bach Toccata (8-bit Arcade)** - Gyruss-inspired chiptune version
- **Bach-esque (Algorithmic)** - Procedurally generated baroque-style music
- **Baroque Chamber** - Six-channel ensemble with strings and harpsichord

Each tab shows the pipeline script alongside playable audio.

## Why This Matters

- **Composable** - Chain stages with Unix pipes
- **Deterministic** - Single seed controls entire pipeline
- **Debuggable** - JSONL works with grep, jq, head
- **Copyright-Safe** - Pure algorithm, no sample licensing
- **Version-Controllable** - Scripts you can diff and share

Build entire arrangements with shell scripts. No DAW required. No sample library licensing. Just pipes.

## Technology

| Component | Choice |
|-----------|--------|
| **Language** | Rust |
| **Format** | JSONL event stream |
| **Output** | Standard MIDI files |
| **Playback** | FluidSynth + SoundFont |

<div class="references-section" markdown="1">

## References

| Topic | Link |
|-------|------|
| **Analog Synthesizers** | [Code Self Study](https://forum.codeselfstudy.com/t/analog-synthesizers/2511) |
| **Drum Synthesis** | [JavaScript Drum Synthesis](https://www.nickwritesablog.com/drum-synthesis-in-javascript/) |
| **Generative Music** | [Code Self Study](https://forum.codeselfstudy.com/t/generative-music/2512) |
| **Music Projects** | [Software and Hardware](https://forum.codeselfstudy.com/t/music-projects-software-and-hardware/2434) |
| **FOSS Music Tools** | [Open Source Music Production](https://forum.codeselfstudy.com/t/free-and-open-source-software-i-use-for-music-production/2694) |
| **Eurorack Programming** | [Patch.Init() Tutorial](https://forum.codeselfstudy.com/t/program-your-very-own-eurorack-module-with-patch-init/2869) |
| **Opusmodus** | [Algorithmic Composition in Lisp](https://opusmodus.com/) |

</div>

---


*Unix philosophy applied to music. Small tools, text streams, infinite possibilities.*
