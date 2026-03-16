#!/bin/bash
# Validate post frontmatter based on category requirements

cd "$(dirname "$0")/.." || exit 1

errors=0

echo "=== Post Validation ==="
echo

# TBT posts must have repo_url
echo "Checking TBT posts for repo_url..."
for file in _posts/*tbt*.md; do
    if [ -f "$file" ]; then
        if ! grep -q "^repo_url:" "$file"; then
            echo "  ERROR: $file missing repo_url"
            ((errors++))
        fi
    fi
done

# Posts with video_url should have video_title
echo "Checking video posts for video_title..."
for file in _posts/*.md; do
    if grep -q "^video_url:" "$file"; then
        if ! grep -q "^video_title:" "$file"; then
            echo "  ERROR: $file has video_url but missing video_title"
            ((errors++))
        fi
    fi
done

# Series posts must have series_part
echo "Checking series posts for series_part..."
for file in _posts/*.md; do
    if grep -q "^series:" "$file"; then
        if ! grep -q "^series_part:" "$file"; then
            echo "  ERROR: $file has series but missing series_part"
            ((errors++))
        fi
    fi
done

# Vibe-coding posts should have repo_url
echo "Checking vibe-coding posts for repo_url..."
for file in _posts/*.md; do
    if grep -q "categories:.*vibe-coding" "$file"; then
        if ! grep -q "^repo_url:" "$file"; then
            basename=$(basename "$file")
            # Skip known exceptions (posts about vibe-coding concept, not a specific project)
            if [[ ! "$basename" =~ "five-ml-concepts" ]] && [[ ! "$basename" =~ "how-ai-learns" ]]; then
                echo "  ERROR: $file has vibe-coding category but missing repo_url"
                ((errors++))
            fi
        fi
    fi
done

# All posts should have abstract
echo "Checking all posts for abstract..."
for file in _posts/*.md; do
    if ! grep -q "^abstract:" "$file"; then
        echo "  ERROR: $file missing abstract"
        ((errors++))
    fi
done

# All posts should have keywords
echo "Checking all posts for keywords..."
for file in _posts/*.md; do
    if ! grep -q "^keywords:" "$file"; then
        echo "  ERROR: $file missing keywords"
        ((errors++))
    fi
done

# All posts must use 00:15:00 time for scheduled publishing
echo "Checking all posts use 00:15:00 time..."
for file in _posts/*.md; do
    date_line=$(grep "^date:" "$file" | head -1)
    if [ -n "$date_line" ]; then
        # Extract the time portion
        time_part=$(echo "$date_line" | grep -o '[0-9][0-9]:[0-9][0-9]:[0-9][0-9]')
        if [ -n "$time_part" ] && [ "$time_part" != "00:15:00" ]; then
            echo "  WARNING: $file uses time $time_part (should be 00:15:00)"
            echo "           Posts with wrong times may not publish on schedule!"
            # Count as warning, not error, since old posts may have different times
        fi
    fi
done

echo
if [ $errors -eq 0 ]; then
    echo "=== All validations passed ==="
    exit 0
else
    echo "=== $errors validation error(s) found ==="
    exit 1
fi
