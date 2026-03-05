#!/bin/bash
# Validate scheduled posts - check their status before and after publication
#
# Usage:
#   ./scripts/validate-scheduled.sh              # Show all scheduled posts
#   ./scripts/validate-scheduled.sh --check-live # Also verify live site status

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$(dirname "$SCRIPT_DIR")"
PUBLISH_DIR="$HOME/github/software-wrighter-lab/sw-lab.github.io.git"
SITE_URL="https://software-wrighter-lab.github.io"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CHECK_LIVE=false
if [ "$1" = "--check-live" ]; then
    CHECK_LIVE=true
fi

echo "=== Scheduled Posts Validation ==="
echo ""
echo "Current time: $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "Cron runs at: 00:30 Pacific daily"
echo ""

# Get current time in various formats for comparison
NOW_EPOCH=$(date +%s)
TODAY=$(date +%Y-%m-%d)

# Track posts by status
PAST_POSTS=()
FUTURE_POSTS=()
WRONG_TIME_POSTS=()
ERRORS=0

echo "=== Posts in Publishing Repo ==="
echo ""

for post_file in "$PUBLISH_DIR/_posts"/*.md; do
    [ -f "$post_file" ] || continue

    BASENAME=$(basename "$post_file" .md)

    # Extract date from frontmatter
    DATE_LINE=$(grep "^date:" "$post_file" | head -1)
    if [ -z "$DATE_LINE" ]; then
        echo -e "${RED}ERROR: $BASENAME - no date in frontmatter${NC}"
        ((ERRORS++))
        continue
    fi

    # Parse the date
    # Format: date: 2026-02-25 00:15:00 -0800
    POST_DATE=$(echo "$DATE_LINE" | sed 's/date: *//' | tr -d '"')
    POST_DATE_ONLY=$(echo "$POST_DATE" | cut -d' ' -f1)
    POST_TIME=$(echo "$POST_DATE" | cut -d' ' -f2)
    POST_TZ=$(echo "$POST_DATE" | cut -d' ' -f3)

    # Check if time is 00:15:00
    if [ "$POST_TIME" != "00:15:00" ]; then
        WRONG_TIME_POSTS+=("$BASENAME ($POST_TIME)")
    fi

    # Determine if post is past or future
    # Convert to epoch for comparison (simplified - assumes -0800)
    if [[ "$POST_DATE_ONLY" < "$TODAY" ]]; then
        PAST_POSTS+=("$BASENAME")
    elif [[ "$POST_DATE_ONLY" > "$TODAY" ]]; then
        FUTURE_POSTS+=("$BASENAME|$POST_DATE_ONLY")
    else
        # Same day - check time
        PAST_POSTS+=("$BASENAME")
    fi
done

# Report wrong times
if [ ${#WRONG_TIME_POSTS[@]} -gt 0 ]; then
    echo -e "${RED}WRONG TIME (should be 00:15:00):${NC}"
    for post in "${WRONG_TIME_POSTS[@]}"; do
        echo "  - $post"
    done
    echo ""
    ERRORS=$((ERRORS + ${#WRONG_TIME_POSTS[@]}))
fi

# Report future posts (scheduled)
if [ ${#FUTURE_POSTS[@]} -gt 0 ]; then
    echo -e "${BLUE}SCHEDULED (future dates):${NC}"
    for entry in "${FUTURE_POSTS[@]}"; do
        POST=$(echo "$entry" | cut -d'|' -f1)
        DATE=$(echo "$entry" | cut -d'|' -f2)
        echo "  - $DATE: $POST"
    done
    echo ""
    echo "  These will publish at 00:30 Pacific on their scheduled dates."
else
    echo "No future-dated posts scheduled."
fi
echo ""

# Check live site for past posts (optional)
if [ "$CHECK_LIVE" = true ]; then
    echo "=== Live Site Verification ==="
    echo ""

    # Check last 7 days of posts
    MISSING_LIVE=()
    FOUND_LIVE=0

    for i in $(seq 0 6); do
        CHECK_DATE=$(date -v-${i}d +%Y-%m-%d 2>/dev/null || date -d "-$i days" +%Y-%m-%d)

        for post_file in "$PUBLISH_DIR/_posts/$CHECK_DATE"*.md; do
            [ -f "$post_file" ] || continue

            BASENAME=$(basename "$post_file" .md)
            YEAR=$(echo "$BASENAME" | cut -d'-' -f1)
            MONTH=$(echo "$BASENAME" | cut -d'-' -f2)
            DAY=$(echo "$BASENAME" | cut -d'-' -f3)
            SLUG=$(echo "$BASENAME" | cut -d'-' -f4-)

            # Check if URL returns 200
            POST_URL="$SITE_URL/$YEAR/$MONTH/$DAY/$SLUG/"
            HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$POST_URL")

            if [ "$HTTP_STATUS" = "200" ]; then
                ((FOUND_LIVE++))
            else
                MISSING_LIVE+=("$BASENAME (HTTP $HTTP_STATUS)")
            fi
        done
    done

    if [ ${#MISSING_LIVE[@]} -gt 0 ]; then
        echo -e "${RED}MISSING FROM LIVE SITE:${NC}"
        for post in "${MISSING_LIVE[@]}"; do
            echo "  - $post"
        done
        ERRORS=$((ERRORS + ${#MISSING_LIVE[@]}))
    else
        echo -e "${GREEN}All $FOUND_LIVE posts from last 7 days are live.${NC}"
    fi

    echo ""

    # Check index pages include recent posts
    echo "Checking index pages..."
    YESTERDAY=$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d "yesterday" +%Y-%m-%d)

    for page in "" "abstracts/" "index-all/"; do
        PAGE_NAME=${page:-"home"}
        FOUND_YESTERDAY=$(curl -s "$SITE_URL/$page" | grep -c "$YESTERDAY" || true)
        if [ "$FOUND_YESTERDAY" -gt 0 ]; then
            echo -e "  ${GREEN}$PAGE_NAME: Contains yesterday's date${NC}"
        else
            echo -e "  ${YELLOW}$PAGE_NAME: No yesterday's date found (may be OK)${NC}"
        fi
    done
fi

# Summary
echo ""
echo "=== Summary ==="
echo "Total posts in repo: $((${#PAST_POSTS[@]} + ${#FUTURE_POSTS[@]}))"
echo "Scheduled (future): ${#FUTURE_POSTS[@]}"
echo "Published (past): ${#PAST_POSTS[@]}"

if [ $ERRORS -gt 0 ]; then
    echo ""
    echo -e "${RED}Found $ERRORS issue(s) requiring attention${NC}"
    exit 1
else
    echo ""
    echo -e "${GREEN}All scheduled posts configured correctly${NC}"
    exit 0
fi
