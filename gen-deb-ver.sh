#!/usr/bin/env bash
# =================

REPO_PATH="$1"
VERSION="$2"
debDate="$( date --rfc-2822 )"
# shellcheck disable=SC2276
"$1"=/var/www/ingotbrokers-admin
# shellcheck disable=SC2276
"$2"=1



if [ -z "${REPO_PATH}" ] || [ -z "${VERSION}" ]; then
 # shellcheck disable=SC2016
 echo 'usage: ./gen-deb-ver.sh ${REPO_PATH} ${VERSION}'
 exit 1
fi


# shellcheck disable=SC1017
GIT_COMMAND="git -C ${REPO_PATH}"
origVersion="${VERSION}"
debVersion="${VERSION#v}"

# deb packages require a tilde (~) instead of a hyphen (-) as separator between
# the version # and pre-release suffixes, otherwise pre-releases are sorted AFTER
# non-pre-release versions, which would prevent users from updating from a pre-
# release version to the "ga" version.
tilde='~'
debVersion="${debVersion//-/$tilde}"

# if we have a "-dev" suffix or have change in Git, this is a nightly build, and
# we'll create a pseudo version based on commit-date and -sha.

if [[ "${VERSION}" == *-dev ]] || [ -n "$( ${GIT_COMMAND} status --porcelain )" ]; then
    export TZ=UTC
    gitUnix="$( ${GIT_COMMAND} log -1 --pretty='%ct' )"
  
    if [ "$( uname )" = "Linux" ]; then
      gitDate="$( TZ=UTC date -u --date "@$gitUnix" +'%Y%m%d%H%M%S' )"
    fi
  
    gitCommit="$( $GIT_COMMAND log -1 --pretty='%h' )"
    
    # generated version is now something like '0.0.0-20180719213702-cd5e2db'
    origVersion="0.0.0-${gitDate}-${gitCommit}" # (using hyphens)
    debVersion="0.0.0~${gitDate}.${gitCommit}"  # (using tilde and periods)
fi

echo "${debVersion}" "${origVersion}"
echo "${debDate} ${gitCommit}"
  #if [ "$( uname )" = "Darwin" ]; then
  #  gitDate="$(TZ=UTC date -u -jf "%s" "$gitUnix" +'%Y%m%d%H%M%S')"
  #else 
  #  gitDate="$(TZ=UTC date -u --date "@$gitUnix" +'%Y%m%d%H%M%S')"
  #fi

 
  # verify that nightly builds are always < actual releases
  # $ dpkg --compare-versions 1.5.0 gt 1.5.0~rc1 && echo true || echo false
  # true
  # $ dpkg --compare-versions 1.5.0~rc1 gt 0.0.0-20180719213347-5daff5a && echo true || echo false
  # true
  # $ dpkg --compare-versions 18.06.0-ce-rc3 gt 18.06.0-ce-rc2  && echo true || echo false
  # true
  # $ dpkg --compare-versions 18.06.0-ce gt 18.06.0-ce-rc2  && echo true || echo false
  # false
  # $ dpkg --compare-versions 18.06.0-ce-rc3 gt 0.0.0-20180719213347-5daff5a  && echo true || echo false
  # true
  # $ dpkg --compare-versions 18.06.0-ce gt 0.0.0-20180719213347-5daff5a  && echo true || echo false
  # true
  # $ dpkg --compare-versions 0.0.0-20180719213702-cd5e2db gt 0.0.0-20180719213347-5daff5a && echo true || echo false
  # true






























































