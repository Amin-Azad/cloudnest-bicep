#!/usr/bin/env bash

set -euo pipefail

if ! command -v git >/dev/null 2>&1; then
  echo "git is required" >&2
  exit 1
fi

if ! command -v grep >/dev/null 2>&1; then
  echo "grep is required" >&2
  exit 1
fi

tracked_files=()
while IFS= read -r file; do
  if [[ -f "$file" && "$file" != 'src/package-lock.json' ]]; then
    tracked_files+=("$file")
  fi
done < <(git ls-files --cached --others --exclude-standard)

if ((${#tracked_files[@]} == 0)); then
  echo "No tracked files found" >&2
  exit 1
fi

failed=0

check_pattern() {
  local label="$1"
  local pattern="$2"

  if grep -EInI -- "$pattern" "${tracked_files[@]}"; then
    echo "Repository hygiene check failed: $label" >&2
    failed=1
  fi
}

check_pattern "email address found" '[[:alnum:]._%+-]+@[[:alnum:].-]+\.[[:alpha:]]{2,}'
check_pattern "Azure subscription resource ID found" '/subscriptions/[0-9a-f]{8}-[0-9a-f-]{27,36}'
check_pattern "private endpoint NIC identifier found" '\.nic\.[0-9a-f]{8}-[0-9a-f-]{27,36}'
check_pattern "Azure portal deep link found" 'portal\.azure\.com/#'

if ((failed != 0)); then
  exit 1
fi

echo "Repository hygiene checks passed"
