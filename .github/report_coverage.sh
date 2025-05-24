#!/bin/bash

# Usage: ./coverage_check.sh 85
# Default to 80% if not passed
THRESHOLD_PERCENT="${1:-80}"

# Path to the JSON file
JSON_FILE="coverage_report.json"

# Extract totals from JSON
read -r total_hittable_modified_lines total_hit_on_modified_lines < <(
    jq -r '
    reduce to_entries[] as $entry (
      [0, 0];
      if $entry.value.total_hittable_modified_lines > 0 then
        [
          .[0] + $entry.value.total_hittable_modified_lines,
          .[1] + $entry.value.total_hit_on_modified_lines
        ]
      else
        .
      end
    ) | @tsv
  ' "$JSON_FILE"
)

if [ "$total_hittable_modified_lines" -eq 0 ]; then
    echo "No modified lines found — skipping check."
    exit 0
fi

# Calculate ratio and percentage
ratio=$(echo "scale=4; $total_hit_on_modified_lines / $total_hittable_modified_lines" | bc)
percentage=$(echo "$ratio * 100" | bc | awk '{printf "%.0f", $0}')

echo "Modified Line Hit Coverage: $percentage% (Threshold: $THRESHOLD_PERCENT%)"

# Compare with threshold
if [ "$percentage" -lt "$THRESHOLD_PERCENT" ]; then
    echo "❌ Coverage below threshold. Failing. Your coverage is $percentage%. you need to increase it to at least $THRESHOLD_PERCENT%."
    exit 1
else
    echo "✅ Coverage meets threshold."
    exit 0
fi
