# Daily Publish Workflow

## The Problem

GitHub Pages does NOT automatically rebuild at midnight. Scheduled posts (dated for "today") won't appear until a push triggers a rebuild.

**Every day with a scheduled post requires an explicit push to trigger the build.**

## Manual Fix

From the publishing repo (`sw-lab.github.io.git`):

```bash
cd ~/github/software-wrighter-lab/sw-lab.github.io.git
git commit --allow-empty -m "Daily rebuild trigger" && git push
```

## Automated Solution: Cron Job

### Option 1: Local Cron (macOS)

Edit crontab:
```bash
crontab -e
```

Add this line to trigger rebuild at 12:05 AM Pacific daily:
```cron
5 0 * * * cd ~/github/software-wrighter-lab/sw-lab.github.io.git && git commit --allow-empty -m "Daily rebuild trigger $(date +\%Y-\%m-\%d)" && git push
```

### Option 2: GitHub Actions (Recommended) ✓ IMPLEMENTED

The publishing repo (`sw-lab.github.io.git`) has this workflow at `.github/workflows/daily-rebuild.yml`:

```yaml
name: Daily Rebuild

on:
  schedule:
    # 08:30 UTC = 00:30 AM Pacific (PST) / 01:30 AM Pacific (PDT)
    - cron: '30 8 * * *'
  workflow_dispatch:  # Allow manual trigger from GitHub UI

jobs:
  rebuild:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Trigger GitHub Pages rebuild
        run: |
          git config user.name "GitHub Actions"
          git config user.email "actions@github.com"
          git commit --allow-empty -m "Daily rebuild trigger $(date +%Y-%m-%d)"
          git push
```

**Schedule:** Runs daily at 00:30 AM Pacific time (08:30 UTC)

**Manual trigger:** Can also be triggered manually from GitHub Actions UI via "workflow_dispatch"

## Timezone Alignment

**GitHub Actions cron**: Always uses **UTC** (no exceptions)
- `cron: '30 8 * * *'` = 08:30 UTC

**Jekyll post dates**: Use the timezone specified in frontmatter
- `date: 2026-02-04 00:00:00 -0800` = midnight PST = 08:00 UTC

**The math:**

| What | Local Time | UTC |
|------|------------|-----|
| Post publishes | 00:00 PST (-0800) | 08:00 UTC |
| Workflow runs | 00:30 PST | 08:30 UTC |
| Gap | | **+30 min** ✓ |

The workflow runs 30 minutes after posts dated midnight Pacific become valid in UTC.

**Important:** The `-0800` (or `-0700` for PDT) in Jekyll frontmatter tells Jekyll the post time is Pacific. GitHub converts to UTC for comparison.

### Option 3: Simple Shell Script

Create `~/bin/daily-blog-rebuild.sh`:

```bash
#!/bin/bash
cd ~/github/software-wrighter-lab/sw-lab.github.io.git
git pull --rebase
git commit --allow-empty -m "Daily rebuild trigger $(date +%Y-%m-%d)"
git push
```

Make executable:
```bash
chmod +x ~/bin/daily-blog-rebuild.sh
```

Then add to crontab:
```cron
5 0 * * * ~/bin/daily-blog-rebuild.sh >> ~/logs/blog-rebuild.log 2>&1
```

## Verification

After the cron runs, check:
1. GitHub Actions: https://github.com/software-wrighter-lab/software-wrighter-lab.github.io/actions
2. Live site: https://software-wrighter-lab.github.io/

## REMEMBER

**When publishing a post for "today", ALWAYS do an empty push to trigger the rebuild!**
