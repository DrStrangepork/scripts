#!/usr/bin/env bash

if ! date --version | grep -q GNU; then
    >&2 echo git-commit-dates.sh requires GNU  \`date\`
    exit 1
fi

# IFS=$'\n'
for FILE in $(git ls-files | sort); do
    TIME=$(git log --pretty=format:%cd -n 1 --date=iso -- "$FILE")
    TIME=$(date --date="$TIME" +%Y%m%d%H%M.%S)
    touch -m -t "$TIME" "$FILE"
done
