#!/bin/bash
set -e

# Perform pre-release checks.
# Args:
# version number
# maintainer email address

CABAL_FILE=$(ls *.cabal)
CHANGELOG_FILE="CHANGELOG.md"

die () {
    echo
    echo >&2 "$@"
    echo
    exit 1
}

# Main
[ "$#" -eq 2 ] || die "Specify release version number and maintainer's email address."

RELEASE_VERSION="$1"
MAINTAINER_EMAIL="$2"

echo "Running pre-release checks for version ${RELEASE_VERSION}"

# Cabal: Ensure version number matches release version.
CABAL_VERSION_FIELD=$(awk '$1=="version:"{print $2}' "${CABAL_FILE}")

if [ -z ${CABAL_VERSION_FIELD} ];
then
  die "Couldn't find version number in ${CABAL_FILE}"
fi

CABAL_VERSION_VALID=true
if [ ${CABAL_VERSION_FIELD} != ${RELEASE_VERSION} ];
then
  CABAL_VERSION_VALID=false
  echo "You need to update the version number in ${CABAL_FILE} to ${RELEASE_VERSION}"
fi

# Cabal: Ensure bug-reports field exists and is correct.
CABAL_BUG_REPORTS_FIELD=$(awk '$1=="bug-reports:"{print $2}' "${CABAL_FILE}")

if [ -z ${CABAL_BUG_REPORTS_FIELD} ];
then
  die "Couldn't find bug-reports field in ${CABAL_FILE}"
fi

REPO_GIT_URL=$(git config --get remote.origin.url)
EXPECTED_GIT_URL="${REPO_GIT_URL%.git}"
EXPECTED_CABAL_BUG_REPORTS="${EXPECTED_GIT_URL}/issues"

CABAL_BUG_REPORTS_VALID=true
if [ ${CABAL_BUG_REPORTS_FIELD} != ${EXPECTED_CABAL_BUG_REPORTS} ];
then
  CABAL_BUG_REPORTS_VALID=false
  echo "You need to change the bug-reports field in ${CABAL_FILE} to ${EXPECTED_CABAL_BUG_REPORTS}"
fi

# Cabal: Ensure homepage field exists and is correct.
CABAL_HOMEPAGE_FIELD=$(awk '$1=="homepage:"{print $2}' "${CABAL_FILE}")

if [ -z ${CABAL_HOMEPAGE_FIELD} ];
then
  die "Couldn't find homepage field in ${CABAL_FILE}"
fi

CABAL_HOMEPAGE_VALID=true
if [ ${CABAL_HOMEPAGE_FIELD} != ${EXPECTED_GIT_URL} ];
then
  CABAL_HOMEPAGE_VALID=false
  echo "You need to change the homepage field in ${CABAL_FILE} to ${EXPECTED_GIT_URL}"
fi

# Cabal: Ensure maintainer exists and is correct.
CABAL_MAINTAINER_FIELD=$(awk '$1=="maintainer:"{print $2}' "${CABAL_FILE}")

if [ -z ${CABAL_MAINTAINER_FIELD} ];
then
  die "Couldn't find maintainer field in ${CABAL_FILE}"
fi

CABAL_MAINTAINER_VALID=true
if [[ ! "${CABAL_MAINTAINER_FIELD}" =~ "${MAINTAINER_EMAIL}" ]];
then
  CABAL_MAINTAINER_VALID=false
  echo "The maintainer field in ${CABAL_FILE} needs to include ${MAINTAINER_EMAIL}"
fi

# Cabal: Ensure source-repository entry exists and is correct.
EXPECTED_SOURCE_REPOSITORY_LOCATION="${EXPECTED_GIT_URL#https:\/\/}"
CABAL_SOURCE_REPOSITORY=$(awk '$1=="source-repository"{print $1}' "${CABAL_FILE}")

if [ -z ${CABAL_SOURCE_REPOSITORY} ];
then
  die "Couldn't find source-repository field in ${CABAL_FILE}"
fi

FULL_GIT_URL="git://${EXPECTED_SOURCE_REPOSITORY_LOCATION}.git"
CABAL_SOURCE_REPOSITORY_LOCATION=$(awk '$1=="location:"{print $2}' "${CABAL_FILE}")

CABAL_SOURCE_REPOSITORY_VALID=true
if [ -z ${CABAL_SOURCE_REPOSITORY_LOCATION} ] || [ ${CABAL_SOURCE_REPOSITORY_LOCATION} != "${FULL_GIT_URL}" ];
then
  CABAL_SOURCE_REPOSITORY_VALID=false
  echo "You need to change the source-repository's location in ${CABAL_FILE} to ${FULL_GIT_URL}"
fi

# Changelog: Ensure it contains an entry for this release version.
REGEX="##\s+${RELEASE_VERSION}\s+--\s+[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}"
CHANGELOG_VERSION=$(grep -Eo "$REGEX" "${CHANGELOG_FILE}" || true)

CHANGELOG_VERSION_VALID=true
if [ -z "${CHANGELOG_VERSION}" ];
then
  CHANGELOG_VERSION_VALID=false
  echo "You need to add or correct the entry in ${CHANGELOG_FILE} for version ${RELEASE_VERSION}"
fi

CHECKS=(
  "$CABAL_VERSION_VALID"
  "$CABAL_BUG_REPORTS_VALID"
  "$CABAL_HOMEPAGE_VALID"
  "$CABAL_MAINTAINER_VALID"
  "$CABAL_SOURCE_REPOSITORY_VALID"
  "$CHANGELOG_VERSION_VALID"
)

if [[ ${CHECKS[*]} == *false* ]];
then
  die "Please correct errors and commit them before trying again."
fi

echo "Everything looks good."
echo
