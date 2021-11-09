#!/usr/bin/env bash

set -euo pipefail

BASE_PATH="$(cd "$(dirname "$0")" && pwd)"

cd "${GITHUB_WORKSPACE}/${INPUT_WORKDIR}" || exit 1

TEMP_PATH="$(mktemp -d)"
PATH="${TEMP_PATH}:$PATH"
export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

REVIEWDOG_VERSION="0.13.0"
echo "::group::🐶 Installing reviewdog ${REVIEWDOG_VERSION} ... https://github.com/reviewdog/reviewdog"
wget "https://github.com/reviewdog/reviewdog/releases/download/v${REVIEWDOG_VERSION}/reviewdog_${REVIEWDOG_VERSION}_Linux_x86_64.tar.gz"
tar -zxf "reviewdog_${REVIEWDOG_VERSION}_Linux_x86_64.tar.gz"
ls -al .
ls -al "reviewdog_${REVIEWDOG_VERSION}_Linux_x86_64/"
mv "reviewdog_${REVIEWDOG_VERSION}_Linux_x86_64/reviewdog" "${BASE_PATH}/reviewdog"
chmod +x "${BASE_PATH}/reviewdog"
echo '::endgroup::'

echo '::group::🐍 Installing pyright ...'
if [ -z "${INPUT_PYRIGHT_VERSION:-}" ]; then
  npm install pyright
else
  npm install "pyright@${INPUT_PYRIGHT_VERSION}"
fi
echo '::endgroup::'

PYRIGHT_ARGS=(--outputjson)

if [ -n "${INPUT_PYTHON_PLATFORM:-}" ] ; then
  PYRIGHT_ARGS+=(--pythonplatform "$INPUT_PYTHON_PLATFORM")
fi

if [ -n "${INPUT_PYTHON_VERSION:-}" ] ; then
  PYRIGHT_ARGS+=(--pythonversion "$INPUT_PYTHON_VERSION")
fi

if [ -n "${INPUT_TYPESHED_PATH:-}" ] ; then
  PYRIGHT_ARGS+=(--typeshed-path "$INPUT_TYPESHED_PATH")
fi

if [ -n "${INPUT_VENV_PATH:-}" ] ; then
  PYRIGHT_ARGS+=(--venv-path "$INPUT_VENV_PATH")
fi

if [ -n "${INPUT_PROJECT:-}" ] ; then
  PYRIGHT_ARGS+=(--project "$INPUT_PROJECT")
fi

if [ -n "${INPUT_LIB:-}" ] ; then
  if [ "${INPUT_LIB^^}" != "FALSE" ] ; then
    PYRIGHT_ARGS+=(--lib)
  fi
fi

echo '::group::🔎 Running pyright with reviewdog 🐶 ...'
# shellcheck disable=SC2086
"$(npm bin)/pyright" "${PYRIGHT_ARGS[@]}" ${INPUT_PYRIGHT_FLAGS:-} |
  python3 "${BASE_PATH}/pyright_to_rdjson.py" |
  "${BASE_PATH}/reviewdog" -f=rdjson \
    -name="${INPUT_TOOL_NAME}" \
    -reporter="${INPUT_REPORTER:-github-pr-review}" \
    -filter-mode="${INPUT_FILTER_MODE}" \
    -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
    -level="${INPUT_LEVEL}" \
    ${INPUT_REVIEWDOG_FLAGS}

reviewdog_rc=$?
echo '::endgroup::'
exit $reviewdog_rc
