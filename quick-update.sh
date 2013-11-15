#!/bin/sh
IFS="
"
git fetch upstream
for upstream in $(git branch -a | grep upstream | cut -d / -f 2-200)
do
	mainbranch="$(echo "${upstream}" | cut -d / -f 2-200)"
	git branch -f "${mainbranch}" "${upstream}" |  grep -v "set up to track remote branch"
done
