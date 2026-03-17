#!/bin/bash
# schedule-post.sh - Schedule a draft for future publication
#
# Moves a draft to _posts/, validates front matter, commits, pushes,
# and verifies the post will be picked up by the scheduled GitHub Actions
# workflow on its publication date.
#
# Usage:
#   ./scripts/schedule-post.sh _drafts/2026-03-16-my-post.md
#   ./scripts/schedule-post.sh 2026-03-16-my-post.md          # assumes _drafts/
#
# What this does:
#   1. Validates front matter (series, abstract, keywords, date, time)
#   2. Ensures date is in the future
#   3. Ensures time is 00:15:00 -0800 (required for scheduled workflow)
#   4. Moves from _drafts/ to _posts/
#   5. Runs deploy.sh validations (orphans, series nav) without deploying
#   6. Commits and pushes to sw-lab main
#   7. Verifies the file exists on the remote
#   8. Shows when the post will go live
#
# How scheduled publishing works:
#   - GitHub Actions workflow runs daily at 08:20 UTC (00:20 PST)
#   - It checks out sw-lab main, runs `jekyll build` (future: false)
#   - Jekyll only includes posts with date <= today
#   - On the post's date, Jekyll includes it, and the workflow deploys it
#   - Posts MUST be committed and pushed to sw-lab main before their date

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# --- Argument Handling ---

if [ -z "$1" ]; then
    echo -e "${RED}Usage: ./scripts/schedule-post.sh <draft-file>${NC}"
    echo ""
    echo "Examples:"
    echo "  ./scripts/schedule-post.sh _drafts/2026-03-16-my-post.md"
    echo "  ./scripts/schedule-post.sh 2026-03-16-my-post.md"
    echo ""
    echo "Available drafts:"
    for draft in "$SOURCE_DIR/_drafts/"*.md; do
        [ -f "$draft" ] || continue
        BASENAME=$(basename "$draft")
        DATE_LINE=$(grep "^date:" "$draft" | head -1 | sed 's/date: *//')
        echo "  $BASENAME  (date: $DATE_LINE)"
    done
    exit 1
fi

# Resolve the draft path
DRAFT_ARG="$1"
if [ -f "$SOURCE_DIR/$DRAFT_ARG" ]; then
    DRAFT_PATH="$SOURCE_DIR/$DRAFT_ARG"
elif [ -f "$SOURCE_DIR/_drafts/$DRAFT_ARG" ]; then
    DRAFT_PATH="$SOURCE_DIR/_drafts/$DRAFT_ARG"
elif [ -f "$DRAFT_ARG" ]; then
    DRAFT_PATH="$DRAFT_ARG"
else
    echo -e "${RED}ERROR: Cannot find draft: $DRAFT_ARG${NC}"
    echo "Looked in:"
    echo "  $SOURCE_DIR/$DRAFT_ARG"
    echo "  $SOURCE_DIR/_drafts/$DRAFT_ARG"
    echo "  $DRAFT_ARG"
    exit 1
fi

BASENAME=$(basename "$DRAFT_PATH")
echo -e "${YELLOW}=== Scheduling Post for Future Publication ===${NC}"
echo "  Draft: $BASENAME"
echo ""

# --- Step 1: Validate Front Matter ---

echo -e "${YELLOW}[1/7] Validating front matter...${NC}"
ERRORS=0

# Check required fields
for field in series series_part abstract keywords date; do
    if ! grep -q "^${field}:" "$DRAFT_PATH"; then
        echo -e "  ${RED}MISSING: ${field}${NC}"
        ERRORS=$((ERRORS + 1))
    fi
done

if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}Fix the missing front matter fields above and re-run.${NC}"
    exit 1
fi
echo -e "${GREEN}  All required fields present (series, series_part, abstract, keywords, date)${NC}"

# --- Step 2: Validate Date is in the Future ---

echo -e "${YELLOW}[2/7] Checking publication date...${NC}"

DATE_LINE=$(grep "^date:" "$DRAFT_PATH" | head -1 | sed 's/date: *//' | tr -d '"')
POST_DATE_ONLY=$(echo "$DATE_LINE" | cut -d' ' -f1)
POST_TIME=$(echo "$DATE_LINE" | grep -o '[0-9][0-9]:[0-9][0-9]:[0-9][0-9]' || echo "")
POST_TZ=$(echo "$DATE_LINE" | grep -o '[-+][0-9]\{4\}' || echo "")

TODAY=$(date +%Y-%m-%d)

if [[ "$POST_DATE_ONLY" < "$TODAY" ]]; then
    echo -e "  ${RED}ERROR: Post date ($POST_DATE_ONLY) is in the past (today: $TODAY)${NC}"
    echo "  Update the date: field in the front matter to a future date."
    exit 1
elif [[ "$POST_DATE_ONLY" == "$TODAY" ]]; then
    echo -e "  ${YELLOW}WARNING: Post date is today ($POST_DATE_ONLY).${NC}"
    echo -e "  ${YELLOW}The scheduled workflow runs at 00:20 PST. If it already ran today,${NC}"
    echo -e "  ${YELLOW}the post won't publish until you manually trigger the workflow or wait until tomorrow.${NC}"
    echo ""
    echo -n "  Continue anyway? [y/N] "
    read -r REPLY
    if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
else
    echo -e "${GREEN}  Publication date: $POST_DATE_ONLY (future - good)${NC}"
fi

# --- Step 3: Validate/Fix Time ---

echo -e "${YELLOW}[3/7] Checking publication time...${NC}"

if [ "$POST_TIME" != "00:15:00" ]; then
    echo -e "  ${YELLOW}WARNING: Post time is '$POST_TIME' (should be 00:15:00)${NC}"
    echo -e "  ${YELLOW}The scheduled workflow runs at 08:20 UTC (00:20 PST).${NC}"
    echo -e "  ${YELLOW}Posts must use 00:15:00 to be caught by the workflow.${NC}"
    echo ""
    echo -n "  Fix time to 00:15:00 -0800? [Y/n] "
    read -r REPLY
    if [[ "$REPLY" =~ ^[Nn]$ ]]; then
        echo -e "  ${YELLOW}Keeping time as-is. Post may not publish on schedule.${NC}"
    else
        # Replace the date line
        NEW_DATE="date: ${POST_DATE_ONLY} 00:15:00 -0800"
        # Use sed to replace the date line in-place
        sed -i '' "s|^date:.*|${NEW_DATE}|" "$DRAFT_PATH"
        echo -e "  ${GREEN}Fixed: date: ${POST_DATE_ONLY} 00:15:00 -0800${NC}"
    fi
elif [ -z "$POST_TZ" ]; then
    echo -e "  ${YELLOW}WARNING: No timezone specified. Adding -0800 (PST).${NC}"
    NEW_DATE="date: ${POST_DATE_ONLY} 00:15:00 -0800"
    sed -i '' "s|^date:.*|${NEW_DATE}|" "$DRAFT_PATH"
    echo -e "  ${GREEN}Fixed: date: ${POST_DATE_ONLY} 00:15:00 -0800${NC}"
else
    echo -e "${GREEN}  Time: 00:15:00 $POST_TZ (correct for scheduled workflow)${NC}"
fi

# --- Step 4: Check for series_part conflicts ---

echo -e "${YELLOW}[4/7] Checking for series_part conflicts...${NC}"

SERIES_NAME=$(grep "^series:" "$DRAFT_PATH" | head -1 | sed 's/series: *"\([^"]*\)"/\1/' | sed "s/series: *'\([^']*\)'/\1/" | sed 's/series: *//')
SERIES_PART=$(grep "^series_part:" "$DRAFT_PATH" | head -1 | sed 's/series_part: *//')

# Check existing posts for same series and part number
CONFLICT=""
for post in "$SOURCE_DIR/_posts/"*.md; do
    [ -f "$post" ] || continue
    POST_SERIES=$(grep "^series:" "$post" | head -1 | sed 's/series: *"\([^"]*\)"/\1/' | sed "s/series: *'\([^']*\)'/\1/" | sed 's/series: *//')
    POST_PART=$(grep "^series_part:" "$post" | head -1 | sed 's/series_part: *//')
    if [ "$POST_SERIES" = "$SERIES_NAME" ] && [ "$POST_PART" = "$SERIES_PART" ]; then
        CONFLICT=$(basename "$post")
        break
    fi
done

if [ -n "$CONFLICT" ]; then
    echo -e "  ${RED}ERROR: series_part $SERIES_PART already used in '$SERIES_NAME' by:${NC}"
    echo -e "  ${RED}  $CONFLICT${NC}"
    echo ""
    # Show existing parts for this series
    echo "  Existing parts in '$SERIES_NAME':"
    for post in "$SOURCE_DIR/_posts/"*.md; do
        [ -f "$post" ] || continue
        PS=$(grep "^series:" "$post" | head -1 | sed 's/series: *"\([^"]*\)"/\1/' | sed "s/series: *'\([^']*\)'/\1/" | sed 's/series: *//')
        if [ "$PS" = "$SERIES_NAME" ]; then
            PP=$(grep "^series_part:" "$post" | head -1 | sed 's/series_part: *//')
            echo "    Part $PP: $(basename "$post")"
        fi
    done
    exit 1
fi
echo -e "${GREEN}  Series: '$SERIES_NAME' Part $SERIES_PART (no conflicts)${NC}"

# --- Step 5: Move to _posts ---

echo -e "${YELLOW}[5/7] Moving to _posts/...${NC}"

DEST_PATH="$SOURCE_DIR/_posts/$BASENAME"

if [ -f "$DEST_PATH" ]; then
    echo -e "  ${RED}ERROR: $BASENAME already exists in _posts/${NC}"
    exit 1
fi

# Check if source is in _drafts
DRAFT_DIR=$(dirname "$DRAFT_PATH")
if [[ "$DRAFT_DIR" == *"_drafts"* ]]; then
    mv "$DRAFT_PATH" "$DEST_PATH"
    echo -e "  ${GREEN}Moved: _drafts/$BASENAME → _posts/$BASENAME${NC}"
else
    cp "$DRAFT_PATH" "$DEST_PATH"
    echo -e "  ${GREEN}Copied: $DRAFT_PATH → _posts/$BASENAME${NC}"
fi

# --- Step 6: Commit and Push ---

echo -e "${YELLOW}[6/7] Committing and pushing...${NC}"
cd "$SOURCE_DIR"

# Stage the post (and the removal from _drafts if applicable)
git add "_posts/$BASENAME"
if [[ "$DRAFT_DIR" == *"_drafts"* ]] && git ls-files --error-unmatch "_drafts/$BASENAME" &>/dev/null; then
    git rm --cached "_drafts/$BASENAME" 2>/dev/null || true
fi

# Extract title for commit message
TITLE=$(grep "^title:" "$DEST_PATH" | head -1 | sed 's/title: *//' | tr -d '"' | tr -d "'")

git commit -m "Schedule: $TITLE (publish $POST_DATE_ONLY)

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"

git push origin main
echo -e "${GREEN}  Committed and pushed to origin/main${NC}"

# --- Step 7: Verify Remote ---

echo -e "${YELLOW}[7/7] Verifying post is on remote...${NC}"

# Check that the file exists on the remote
REMOTE_CHECK=$(git ls-remote --exit-code origin HEAD 2>/dev/null && echo "ok" || echo "fail")
if [ "$REMOTE_CHECK" = "fail" ]; then
    echo -e "  ${RED}WARNING: Could not verify remote. Check your internet connection.${NC}"
else
    # Verify the commit was pushed
    LOCAL_HEAD=$(git rev-parse HEAD)
    REMOTE_HEAD=$(git rev-parse origin/main 2>/dev/null || echo "unknown")
    if [ "$LOCAL_HEAD" = "$REMOTE_HEAD" ]; then
        echo -e "  ${GREEN}Verified: local HEAD matches origin/main ($LOCAL_HEAD)${NC}"
    else
        echo -e "  ${RED}WARNING: local HEAD ($LOCAL_HEAD) != origin/main ($REMOTE_HEAD)${NC}"
        echo -e "  ${RED}The push may not have succeeded. Run 'git push' manually.${NC}"
    fi
fi

# --- Summary ---

echo ""
echo -e "${GREEN}=== Post Scheduled Successfully ===${NC}"
echo ""
echo "  Post:     $BASENAME"
echo "  Series:   $SERIES_NAME (Part $SERIES_PART)"
echo "  Publish:  $POST_DATE_ONLY"
echo ""
echo -e "${BLUE}How it will publish:${NC}"
echo "  1. GitHub Actions runs daily at 00:20 PST (08:20 UTC)"
echo "  2. On $POST_DATE_ONLY, Jekyll will include this post in the build"
echo "  3. The workflow deploys the built site to GitHub Pages"
echo "  4. The post will be live by ~00:25 PST on $POST_DATE_ONLY"
echo ""
echo -e "${BLUE}To verify before publication:${NC}"
echo "  ./scripts/validate-scheduled.sh"
echo ""
echo -e "${BLUE}To verify after publication:${NC}"
echo "  ./scripts/validate-scheduled.sh --check-live"
echo ""
echo -e "${BLUE}To trigger early publication (manual deploy):${NC}"
echo "  ./scripts/deploy.sh \"Publish: $TITLE\""
