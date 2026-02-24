#!/bin/bash
# Safe deployment script for sw-lab blog
# This script ensures drafts are NEVER published to the live site

set -e  # Exit on any error

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$(dirname "$SCRIPT_DIR")"
PUBLISH_DIR="$HOME/github/software-wrighter-lab/sw-lab.github.io.git"

echo "=== SW-Lab Safe Deployment ==="
echo ""

# Step 1: Kill any running Jekyll server to prevent draft contamination
echo "[1/6] Stopping any running Jekyll servers..."
pkill -f "jekyll serve" 2>/dev/null || true
sleep 1

# Step 2: Clean the _site directory
echo "[2/6] Cleaning _site directory..."
rm -rf "$SOURCE_DIR/_site"

# Step 3: Build WITHOUT drafts or future posts
echo "[3/6] Building site (production mode - NO drafts)..."
cd "$SOURCE_DIR"
bundle exec jekyll build 2>&1 | grep -E "(done in|Error|error)" || true

# Step 4: Verify no drafts leaked through
echo "[4/6] Verifying no draft content..."
DRAFT_DIRS=$(find "$SOURCE_DIR/_site" -type d \( -path "*/2027/*" -o -path "*/2026/0[3-9]/*" -o -path "*/2026/1[0-2]/*" \) 2>/dev/null | head -5)
if [ -n "$DRAFT_DIRS" ]; then
    echo "ERROR: Draft content detected in _site!"
    echo "$DRAFT_DIRS"
    echo "Aborting deployment."
    exit 1
fi
echo "  No draft content found. Safe to deploy."

# Step 5: Copy to publishing repo
echo "[5/6] Copying to publishing repo..."
cd "$PUBLISH_DIR"
rm -rf ./*
cp -r "$SOURCE_DIR/_site/"* .

# Add README for publishing repo
cat > README.md << 'EOF'
# Software Wrighter Lab

A blog about AI, machine learning, and programming.

**Live site:** https://software-wrighter-lab.github.io/

## About

Software Wrighter Lab explores:
- Machine learning concepts and research papers
- AI agents and continuous learning
- Rust, WebAssembly, and systems programming
- Throwback Thursday programming history

## Source

This is the published site. Source repo: [sw-lab](https://github.com/software-wrighter-lab/sw-lab)
EOF

# Step 6: Commit and push
echo "[6/6] Committing and pushing to live..."
git add -A
if git diff --cached --quiet; then
    echo "  No changes to deploy."
else
    COMMIT_MSG="${1:-Deploy: $(date +%Y-%m-%d_%H:%M)}"
    git commit -m "$COMMIT_MSG

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
    git push
    echo ""
    echo "=== Deployment Complete ==="
    echo "Live site: https://software-wrighter-lab.github.io/"
fi
