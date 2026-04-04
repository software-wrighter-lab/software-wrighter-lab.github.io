#!/bin/bash
# validate-scheduled.sh - Check status of scheduled (future-dated) posts
#
# Verifies that future-dated posts in _posts/ are properly configured
# and will be picked up by the scheduled GitHub Actions workflow.
#
# Usage:
#   ./scripts/validate-scheduled.sh              # Show scheduled posts & verify config
#   ./scripts/validate-scheduled.sh --check-live # Also verify recent posts are live
#
# How scheduled publishing works:
#   - Posts with future dates go in _posts/ (NOT _drafts/), committed and pushed
#   - GitHub Actions workflow runs daily at 08:20 UTC (00:20 PST)
#   - Jekyll builds with future: false (default) — only includes posts dated <= today
#   - On a post's date, Jekyll includes it, and the workflow deploys it
#   - Posts MUST use time 00:15:00 to be caught by the 00:20 PST workflow run

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$(dirname "$SCRIPT_DIR")"
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
echo "  Current time: $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "  Workflow runs: 00:20 PST daily (08:20 UTC)"
echo ""

TODAY=$(date +%Y-%m-%d)
ERRORS=0
WARNINGS=0
FUTURE_POSTS=()
TODAY_POSTS=()

# --- Check source repo for future-dated posts in _posts/ ---

echo -e "${YELLOW}[1/4] Scanning _posts/ for future-dated posts...${NC}"

for post_file in "$SOURCE_DIR/_posts/"*.md; do
    [ -f "$post_file" ] || continue

    BASENAME=$(basename "$post_file" .md)
    DATE_LINE=$(grep "^date:" "$post_file" | head -1 | sed 's/date: *//' | tr -d '"')
    POST_DATE_ONLY=$(echo "$DATE_LINE" | cut -d' ' -f1)
    POST_TIME=$(echo "$DATE_LINE" | grep -o '[0-9][0-9]:[0-9][0-9]:[0-9][0-9]' || echo "")

    if [[ "$POST_DATE_ONLY" > "$TODAY" ]]; then
        STATUS="scheduled"
        ISSUES=""

        # Check time
        if [ "$POST_TIME" != "00:15:00" ]; then
            ISSUES="${ISSUES} [WRONG TIME: $POST_TIME]"
            ERRORS=$((ERRORS + 1))
        fi

        # Check required fields
        for field in series series_part abstract keywords; do
            if ! grep -q "^${field}:" "$post_file"; then
                ISSUES="${ISSUES} [MISSING: $field]"
                ERRORS=$((ERRORS + 1))
            fi
        done

        FUTURE_POSTS+=("$POST_DATE_ONLY|$BASENAME|$ISSUES")

    elif [[ "$POST_DATE_ONLY" == "$TODAY" ]]; then
        TODAY_POSTS+=("$BASENAME")
    fi
done

if [ ${#FUTURE_POSTS[@]} -gt 0 ]; then
    echo -e "  ${BLUE}Scheduled posts:${NC}"
    # Sort by date
    IFS=$'\n' SORTED=($(printf '%s\n' "${FUTURE_POSTS[@]}" | sort))
    unset IFS
    for entry in "${SORTED[@]}"; do
        DATE=$(echo "$entry" | cut -d'|' -f1)
        POST=$(echo "$entry" | cut -d'|' -f2)
        ISSUES=$(echo "$entry" | cut -d'|' -f3)
        if [ -n "$ISSUES" ]; then
            echo -e "    ${RED}$DATE: $POST$ISSUES${NC}"
        else
            echo -e "    ${GREEN}$DATE: $POST${NC}"
        fi
    done
else
    echo -e "  ${YELLOW}No future-dated posts found in _posts/.${NC}"
fi

if [ ${#TODAY_POSTS[@]} -gt 0 ]; then
    echo ""
    echo -e "  ${BLUE}Posts dated today ($TODAY):${NC}"
    for post in "${TODAY_POSTS[@]}"; do
        echo "    $post"
    done
fi
echo ""

# --- Check drafts that look ready to schedule ---

echo -e "${YELLOW}[2/4] Checking _drafts/ for posts ready to schedule...${NC}"

READY_DRAFTS=()
for draft_file in "$SOURCE_DIR/_drafts/"*.md; do
    [ -f "$draft_file" ] || continue
    BASENAME=$(basename "$draft_file" .md)
    DATE_LINE=$(grep "^date:" "$draft_file" | head -1 | sed 's/date: *//' | tr -d '"')
    POST_DATE_ONLY=$(echo "$DATE_LINE" | cut -d' ' -f1)

    if [ -n "$POST_DATE_ONLY" ]; then
        # Check how many required fields are present
        FIELDS=0
        for field in series series_part abstract keywords; do
            grep -q "^${field}:" "$draft_file" && FIELDS=$((FIELDS + 1))
        done
        READY_DRAFTS+=("$POST_DATE_ONLY|$BASENAME|$FIELDS/4 fields")
    fi
done

if [ ${#READY_DRAFTS[@]} -gt 0 ]; then
    echo -e "  ${YELLOW}Drafts with dates (not yet scheduled):${NC}"
    IFS=$'\n' SORTED=($(printf '%s\n' "${READY_DRAFTS[@]}" | sort))
    unset IFS
    for entry in "${SORTED[@]}"; do
        DATE=$(echo "$entry" | cut -d'|' -f1)
        POST=$(echo "$entry" | cut -d'|' -f2)
        FIELDS=$(echo "$entry" | cut -d'|' -f3)
        echo -e "    $DATE: $POST ($FIELDS)"
    done
    echo ""
    echo -e "  ${YELLOW}To schedule a draft:${NC}"
    echo "    ./scripts/schedule-post.sh _drafts/FILENAME.md"
else
    echo -e "  ${GREEN}No drafts with dates found.${NC}"
fi
echo ""

# --- Check git status ---

echo -e "${YELLOW}[3/4] Verifying git status for scheduled posts...${NC}"

cd "$SOURCE_DIR"
GIT_ISSUES=0

# Check that future posts are committed
for entry in "${FUTURE_POSTS[@]}"; do
    POST=$(echo "$entry" | cut -d'|' -f2)
    FILENAME="_posts/${POST}.md"

    # Check if tracked by git
    if ! git ls-files --error-unmatch "$FILENAME" &>/dev/null; then
        echo -e "  ${RED}NOT COMMITTED: $FILENAME${NC}"
        echo -e "  ${RED}  This post will NOT publish. Run: git add $FILENAME && git commit && git push${NC}"
        GIT_ISSUES=$((GIT_ISSUES + 1))
        ERRORS=$((ERRORS + 1))
    fi
done

# Check if local is ahead of remote (committed but not pushed)
UNPUSHED=$(git log --oneline origin/main..HEAD -- _posts/ 2>/dev/null || true)
if [ -n "$UNPUSHED" ]; then
    echo -e "  ${RED}UNPUSHED commits affecting _posts/:${NC}"
    echo "$UNPUSHED" | while read -r line; do
        echo -e "    ${RED}$line${NC}"
    done
    echo -e "  ${RED}These posts will NOT publish until pushed. Run: git push${NC}"
    ERRORS=$((ERRORS + 1))
fi

if [ $GIT_ISSUES -eq 0 ] && [ -z "$UNPUSHED" ]; then
    echo -e "  ${GREEN}All scheduled posts are committed and pushed${NC}"
fi
echo ""

# --- Check live site (optional) ---

if [ "$CHECK_LIVE" = true ]; then
    echo -e "${YELLOW}[4/4] Verifying recent posts on live site...${NC}"

    MISSING_LIVE=()
    FOUND_LIVE=0

    # Check last 7 days of posts
    for i in $(seq 0 6); do
        CHECK_DATE=$(date -v-${i}d +%Y-%m-%d 2>/dev/null || date -d "-$i days" +%Y-%m-%d)

        for post_file in "$SOURCE_DIR/_posts/$CHECK_DATE"*.md; do
            [ -f "$post_file" ] || continue

            BASENAME=$(basename "$post_file" .md)
            YEAR=$(echo "$BASENAME" | cut -d'-' -f1)
            MONTH=$(echo "$BASENAME" | cut -d'-' -f2)
            DAY=$(echo "$BASENAME" | cut -d'-' -f3)
            SLUG=$(echo "$BASENAME" | cut -d'-' -f4-)

            POST_URL="$SITE_URL/$YEAR/$MONTH/$DAY/$SLUG/"
            HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$POST_URL")

            if [ "$HTTP_STATUS" = "200" ]; then
                FOUND_LIVE=$((FOUND_LIVE + 1))
            else
                MISSING_LIVE+=("$BASENAME (HTTP $HTTP_STATUS)")
            fi
        done
    done

    if [ ${#MISSING_LIVE[@]} -gt 0 ]; then
        echo -e "  ${RED}MISSING FROM LIVE SITE (last 7 days):${NC}"
        for post in "${MISSING_LIVE[@]}"; do
            echo -e "    ${RED}$post${NC}"
        done
        ERRORS=$((ERRORS + ${#MISSING_LIVE[@]}))
    else
        echo -e "  ${GREEN}All $FOUND_LIVE posts from last 7 days are live${NC}"
    fi
    echo ""
else
    echo -e "${YELLOW}[4/4] Skipping live site check (use --check-live to enable)${NC}"
    echo ""
fi

# --- Summary ---

echo "=== Summary ==="
echo "  Scheduled (future): ${#FUTURE_POSTS[@]}"
echo "  Drafts with dates:  ${#READY_DRAFTS[@]}"
echo "  Published today:    ${#TODAY_POSTS[@]}"

if [ $ERRORS -gt 0 ]; then
    echo ""
    echo -e "${RED}Found $ERRORS issue(s) requiring attention${NC}"
    exit 1
else
    echo ""
    echo -e "${GREEN}All scheduled posts are properly configured${NC}"
    exit 0
fi
