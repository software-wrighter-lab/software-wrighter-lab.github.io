---
layout: post
title: "Lucy 20%: Upgrading My Home AI Cluster"
date: 2026-02-28 00:15:00 -0800
categories: [homelab, ai, hardware]
tags: [lucy, ai-cluster, rtx-3090, voice-cloning, text-to-image, text-to-video, local-ai, homelab, voxcpm, flux, wan]
keywords: "Lucy AI, home AI cluster, RTX 3090, local AI, voice cloning, VoxCPM, FLUX schnell, text-to-image, text-to-video, Wan 2.2, SVD, X99 motherboard, homelab, AI hardware, 24GB VRAM"
author: Software Wrighter
abstract: "Expanding my home AI cluster from 10% to 20% brain power with a new X99 motherboard and RTX 3090. Adding VoxCPM voice cloning, FLUX text-to-image, and Wan 2.2 text-to-video capabilities."
video_url: "https://www.youtube.com/shorts/wJvmBYTge7U"
video_title: "Lucy 20% - AI Cluster Upgrade"
---

<img src="/assets/images/posts/block-beehive.png" class="post-marker" alt="">

Lucy is getting an upgrade. I'm adding an X99 motherboard with an RTX 3090 to expand my AI cluster from 10% to 20% brain power.

<div class="resource-box" markdown="1">

| Resource | Link |
|----------|------|
| **Music Generation** | [music-pipe-rs](https://github.com/softwarewrighter/music-pipe-rs) |
| **Video** | [Lucy 20% Upgrade](https://www.youtube.com/shorts/wJvmBYTge7U)<br>[![Video](https://img.youtube.com/vi/wJvmBYTge7U/mqdefault.jpg){: .video-thumb}](https://www.youtube.com/shorts/wJvmBYTge7U) |

</div>

## New Hardware: Queenbee

The cluster uses bee-themed naming. The new node is called **queenbee**:

| Component | Specification |
|-----------|---------------|
| **Motherboard** | X99 |
| **CPU** | Intel Xeon E5-2660 v4 (28 threads) |
| **RAM** | 64 GB DDR4 ECC |
| **GPU** | RTX 3090 (24GB VRAM) |
| **Storage** | 1TB NVMe SSD + 4TB HDD |

## New AI Capabilities

With queenbee online, Lucy gains several new abilities:

| Capability | Model | What It Does |
|------------|-------|--------------|
| **Voice Cloning** | VoxCPM | High-quality text-to-speech with voice cloning |
| **Text-to-Image** | FLUX schnell | Fast image generation from text prompts |
| **Text-to-Video** | Wan 2.2 | Generate video clips from text descriptions |
| **Image-to-Video** | SVD | Animate still images into video |

## The Cluster Architecture

The cluster now has two nodes:

| Node | Role | GPU |
|------|------|-----|
| **hive** | MuseTalk lip-sync | RTX 3060 (12GB) |
| **queenbee** | Generative AI workloads | RTX 3090 (24GB) |

Together, they handle the full pipeline: generate images, animate them to video, add lip-synced speech, and produce the final output.

## Why Local AI?

Running AI locally means:

- **Privacy** - Data never leaves my network
- **No API costs** - Unlimited generations after hardware investment
- **Customization** - Full control over models and parameters
- **Learning** - Deep understanding of how these systems work

The 24GB of VRAM on the 3090 opens up models that wouldn't fit on smaller cards. FLUX schnell produces high-quality images in seconds. VoxCPM creates natural-sounding speech that can clone voices from short audio samples.

## What's Next

The 20% milestone is just a step. Future upgrades could include:

- Additional GPU nodes for parallel processing
- Larger language models for local inference
- Real-time video generation pipelines
- Integration with more specialized models

The bee hive keeps growing.

---


*Building AI infrastructure one node at a time.*
