# Discord Server Setup: Software Wrighter Lab

Step-by-step instructions for creating and configuring the Discord server.

---

## Step 1: Create the Server

1. Open Discord (desktop app or browser)
2. Click the **+** button in the left sidebar (below your server list)
3. Select **"Create My Own"**
4. Choose **"For a club or community"** (enables community features later)
5. Server name: **Software Wrighter Lab**
6. Skip the icon for now (add later)
7. Click **Create**

### Add Server Description
1. Right-click server name → **Server Settings**
2. Go to **Overview**
3. In the **Server Description** field (300 char limit), enter:

```
A workshop for building small, experimental software tools—often with AI, often just for yourself. Not a debate server. A place to make things.
```

4. Click **Save Changes**

This description appears in invite previews and server discovery.

---

## Step 2: Enable Community Features

This unlocks Member Screening, Announcements, and other useful features.

1. Right-click server name → **Server Settings**
2. Scroll to **Community** section → **Enable Community**
3. Click **Get Started**
4. Check both boxes:
   - [x] Required: Verified email
   - [x] Required: Remove explicit media
5. Select or create channels:
   - Rules channel: `#how-this-server-works` (create new)
   - Updates channel: `#announcements` (create new)
6. Click **Finish Setup**

---

## Step 3: Configure Safety & Verification

### Verification Level
1. Server Settings → **Safety Setup**
2. Under **Verification Level**, select **Medium**:
   > "Members must have a verified email AND be registered on Discord for more than 5 minutes"
3. This blocks most throwaway spam accounts

### AutoMod (optional but recommended)
1. Server Settings → **AutoMod**
2. Enable these rules:
   - **Block Mention Spam**: Max 5 mentions per message
   - **Block Spam Content**: Discord's ML-based spam detection
3. Leave other rules off initially (can add later if needed)

### Member Screening
1. Server Settings → **Safety Setup** → **Membership Screening**
2. Click **Set up Membership Screening**
3. Add a description:
   ```
   Welcome to Software Wrighter Lab!

   This is a community for people who enjoy building small, experimental
   software tools—often with AI, often just for themselves.

   This is not a debate server. It's a workshop.
   ```
4. Add 2-3 rules members must accept:
   - Rule 1: "I understand this is a workshop for building and experimenting, not debating AI ethics"
   - Rule 2: "I will keep discussions constructive and on-topic"
   - Rule 3: "I've read #how-this-server-works"
5. Click **Save**

New members will see this screen and must click "I agree" before accessing channels.

---

## Step 4: Create Categories and Channels

Delete default channels first, then create this structure:

### Category: START HERE
| Channel | Type | Settings |
|---------|------|----------|
| `#welcome` | Text | Read-only (see permissions below) |
| `#how-this-server-works` | Text | Read-only |
| `#announcements` | Text | Read-only (Announcement channel type) |

### Category: MAKING
| Channel | Type | Settings |
|---------|------|----------|
| `#personal-tools-showcase` | Text | Normal |
| `#throwaway-code` | Text | Normal |
| `#maker-lounge` | Text | Normal |
| `#pairing-sessions` | Text | Normal |

### Category: IDEAS
| Channel | Type | Settings |
|---------|------|----------|
| `#context-reduction` | Text | Normal |
| `#llm-reasoning` | Text | Normal |
| `#recursive-models` | Text | Normal |
| `#graphs-over-text` | Text | Normal |
| `#eli5-ml` | Text | Normal |

### Category: SKEPTICISM
| Channel | Type | Settings |
|---------|------|----------|
| `#ai-skeptic-corner` | Text | Normal |

### Category: LIVE
| Channel | Type | Settings |
|---------|------|----------|
| `Maker Room` | Voice | Normal |
| `Pair Programming` | Voice | Normal |
| `Office Hours` | Voice | Normal |

### Category: LINKS OUT
| Channel | Type | Settings |
|---------|------|----------|
| `#github-updates` | Text | Read-only (for webhooks/bots later) |
| `#blog-video-links` | Text | Read-only |

---

## Step 5: Set Channel Permissions

### Make read-only channels
For `#welcome`, `#how-this-server-works`, `#announcements`, `#github-updates`, `#blog-video-links`:

1. Click the channel → Edit Channel (gear icon)
2. Go to **Permissions**
3. Click **@everyone** role
4. Set these permissions:
   - View Channel: **YES** (green check)
   - Send Messages: **NO** (red X)
   - Add Reactions: **YES** (optional, nice for engagement)
5. Save changes

---

## Step 6: Write Welcome Content

### #welcome
```
# Welcome to Software Wrighter Lab

A place for people who enjoy building small, experimental software
tools—often with AI, often just for themselves.

**What this is:**
- A workshop for making and experimenting
- A place to share throwaway code and personal tools
- Discussions about context reduction, LLM reasoning, and practical AI

**What this isn't:**
- A debate forum about whether AI is good or bad
- A place for hype or hot takes
- A support channel for specific products

**Get started:**
1. Read #how-this-server-works
2. Introduce yourself in #maker-lounge
3. Share what you're building in #personal-tools-showcase

**Links:**
- Blog: https://software-wrighter-lab.github.io (coming soon)
- YouTube: [your channel]
- GitHub: https://github.com/software-wrighter-lab
```

### #how-this-server-works
```
# How This Server Works

## Philosophy
This server is for building, testing, and comparing ideas.
Debate is welcome. Culture wars are not.
If something can be tested, we test it.

## Channels

**MAKING** - Share what you're building
- #personal-tools-showcase — Show off your one-off tools
- #throwaway-code — Code that exists for an afternoon
- #maker-lounge — General chat about making things
- #pairing-sessions — Find someone to pair with

**IDEAS** - Discuss concepts
- #context-reduction — Less context, better results
- #llm-reasoning — When thinking helps vs hurts
- #recursive-models — Shrinking problems before solving
- #graphs-over-text — Structure over prose
- #eli5-ml — Explain papers simply

**SKEPTICISM**
- #ai-skeptic-corner — Skepticism welcome, cynicism not

**LIVE** - Voice channels for real-time collaboration

**LINKS OUT** - Announcements from blog/GitHub (read-only)

## Guidelines
1. Be constructive
2. Share what you're actually building/trying
3. Skepticism is welcome if grounded in specifics
4. No drive-by negativity
```

---

## Step 7: Create Invite Link

1. Click the server name → **Invite People**
2. Click **Edit invite link** at the bottom
3. Settings:
   - **Expire after**: Never
   - **Max uses**: No limit
4. Copy the link (looks like: `https://discord.gg/AbCdEfGh`)
5. Save this link — you'll use it in blog posts

**Tip:** You can create a custom/vanity URL if you have Nitro or enough server boosts later.

---

## Step 8: Server Icon & Banner (Optional)

### Server Icon
- Recommended size: 512x512 px
- Keep it simple — initials "SWL" or a minimal logo work well
- Server Settings → Overview → Upload icon

### Server Banner (requires Level 2 boost)
- Size: 960x540 px
- Not needed initially

---

## Step 9: Roles (Optional, Add Later)

Start simple with just @everyone. Add roles if needed:

| Role | Color | Purpose |
|------|-------|---------|
| `@Maker` | Green | Active contributors |
| `@Lurker-friendly` | Gray | People who just want to read |

Don't over-engineer roles at the start. Let the community shape what's needed.

---

## Step 10: Final Checklist

- [ ] Server created with name "Software Wrighter Lab"
- [ ] Server description added
- [ ] Community features enabled
- [ ] Verification level set to Medium
- [ ] Member Screening enabled with rules
- [ ] All categories and channels created
- [ ] Read-only permissions set on announcement channels
- [ ] #welcome message posted
- [ ] #how-this-server-works message posted
- [ ] Permanent invite link created and saved
- [ ] Update blog drafts with real invite link

---

## Invite Link Placeholder

Once created, replace `INVITE_CODE` in these files:
- `blog/topics/personal-software/draft-01.md`
- `blog/topics/context-reduction/draft-01.md`
- `blog/topics/thinking-llms/draft-01.md`
- `docs/plan.md` (footer template)

---

## Optional: GitHub Webhook (Later)

To auto-post GitHub activity to `#github-updates`:

1. In Discord: Channel Settings → Integrations → Webhooks → New Webhook
2. Name it "GitHub" and copy the webhook URL
3. In GitHub repo: Settings → Webhooks → Add webhook
4. Paste Discord URL + `/github` at the end
5. Select events: Pushes, Releases, Issues (optional)

This is optional — set up once you have repos to announce.
