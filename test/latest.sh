#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

expect_commit='04aee52363688426eab74f5d6180c149654a6473'
expect_tagged='b72cc2fda0e8b3792b7b3f7361fc3f917f269433'

tmpclone='/tmp/libming-libming-latest-check'
rm -rf "${tmpclone}"
git clone --depth 1 'https://github.com/libming/libming.git' "${tmpclone}" 2> /dev/null
pushd "${tmpclone}" > /dev/null
git fetch -t 2> /dev/null
commit="$(git rev-parse HEAD)"
tagged="$(git rev-list --tags --max-count=1)"
popd > /dev/null
rm -rf "${tmpclone}"

result=0

if [[ "${tagged}" == "${expect_tagged}" ]]; then
	echo 'Latest tagged commit unchanged'
else
	echo 'Latest tagged commit changed'
	result=1
fi

if [[ "${commit}" == "${expect_commit}" ]]; then
	echo 'HEAD commit on master unchanged'
else
	echo 'HEAD commit on master changed'
	result=1
fi

exit "${result}"
