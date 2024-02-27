#!/usr/bin/env bash
# =================================
#   Helper Script Mainly in Control - Git
# 	Control - Git
#   Primary revision control system
#   && covers variables
## Variables -----------------------------------------------------------------
set -euo pipefail
[ -n "${DEBUG:-}"  ] && set -x
# Lets have some emojis
export WARNING_ICON="⚠️"
export ERROR_ICON="🛑"

BLDRST='\033[1m'
BLDBLK='\033[1;30m'  # Black - Bold
BLDRED='\033[1;31m'  # Red
BLDGRN='\033[1;32m'  # Green
BLDYLW='\033[1;33m'  # Yellow
BLDBLU='\033[1;34m'  # Blue
BLDPUR='\033[1;35m'  # Purple
BLDCYN='\033[1;36m'  # Cyan
BLDWHT='\033[1;37m'  # White

export debDate="$( date --rfc-2822 )"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
RSA_KEY="$( echo "$KEYS" | awk '/ssh-rsa/ {print $1" "$2}' )"

GIT_COMMIT=$( git log -1 --pretty=%H )
GIT_MESSAGE=$( git log -1 --pretty=%B )
GIT_SHORT_COMMIT=$( echo $VERSION | cut -c 1-7 )
GIT_AUTHOR=${CI_COMMIT_AUTHOR}=$( git log -1 --pretty=%an )
GIT_AUTHOR_EMAIL=${CI_COMMIT_EMAIL}=$( git log -1 --pretty=%ae )

export GIT_REVISION=$( git rev-parse --short HEAD )
export GIT_TAG=$( git describe --tags --exact-match 2>/dev/null )
GIT_MOST_RECENT_TAG=$( git describe --tags --abbrev=0 --always )
GIT_COMMAND="git -C ${REPO_PATH}"
GIT_CURRENT_BRANCH=$( git symbolic-ref HEAD --short )
export GIT_DEFAULT_BRANCH=$( git branch -a --contains HEAD | sed -n 3p | awk '{ printf $1 }' )
GIT_DEFAULT_BRANCH=$( git remote show origin | sed -n '/HEAD branch/s/.*: //p' )

## Aliases  -----------------------------------------------------------------
alias gitconfig="\${EDITOR} ~/.gitconfig"
alias gitignore="\${EDITOR} ~/.gitignore"
alias up=pull
alias pu=push
alias br=branch
alias ci=commit
alias co=checkout
alias tag='git tag'
alias rv='remote -v'
alias gdiff="git diff"
alias clone="git clone"
alias fetch='git fetch'
alias stash="git stash"

alias dev="switch dev"
alias main="switch main"
alias master="switch master"
alias GRH="git reset HEAD^"
alias bb='browse bitbucket'
alias gdiff="git --no-pager diff"
alias logwc='log --oneline | wc -l'
## Shell opts -----------------------------------------------------------------

gitUnix="$( ${GIT_COMMAND} log -1 --pretty='%ct' )"
if [ "$( uname )" = "Linux" ]; then
  export TZ=UTC
  export gitDate="$( TZ=UTC date -u --date "@$gitUnix" +'%Y%m%d%H%M%S' )"
fi
gitCommit=$( ${GIT_COMMAND} log -1 --pretty='%h' )

diffs=$( git diff origin/"$GIT_BRANSH" | wc -l )

COPY_BACKUP=$( cp -Rf "$LOCAL_PATH/" "$PREVIEW_DIR/" )
COMPRS_BACKUP=$( zip -r "${ARTIFACT_BASENAME}" dist/ )
RECURS_BACKUP=$( zip -rc --quit "$LOCAL_PATH"/ "$PREVIEW_DIR"/ )
COMPRESS_TAR=$( tar -czf "${ARCHIVE_FILENAME}" -C "${TAR_WORKING_FOLDER}" "${PATHS_TO_ARCHIVE}" )



export DEBIAN_FRONTEND=noninteractiv
export Version="${VERSION#v}"
export HOSTNAME="$( hostname -s )"
export PRIVATE_IP="$( hostname -I )"
export ARCH="$( dpkg --print-architecture )"
export OS_NAME=$(lsb_release -si)


export TZ=UTC


## set functions -----------------------------------------------------------------
# Clone the dev-portal project, if needed
if [ ! -d "$REPO_PATH" ]; then
  echo "⏳ Cloning $REPO_TO_CLONE repo, this might take a while..."
  git clone --depth 1 --branch BRANCH "${REPO_PATH}"
  SHOULD_PULL=false
fi


if [ -f "composer.json" ]; then
  printf "%b\n" "${BLDRED}[installing Composer Dependincies]${BLDRST}"
  composer install --ansi --no-dev --no-script --no-interaction || { echo 'Composer Install Failed' ; exit 1; }
  composer dump-autoload --ansi --no-dev --no-script --no-interaction || { echo 'Composer Dump Failed' ; exit 1; }
fi

## Download changes from origin ##
gitpull() {
    printf "%b\n" "${BLDCYN}[If the directory already existed, pull to ensure the clone is fresh]${BLDRST}"

    git fetch "${REMOTE}" 2>&1 || { printf "%b\n" "${BLDRED}[fetch failed]${BLDRST}" ; exit 1; }

    local SHOULD_PULL=true
    if [ "$SHOULD_PULL" = true ]; then
      git pull --no-edit origin "$GIT_BRANCH"
      git submodule update --init --recursive   
        
      if [ -n "${GIT_PULL_IN_BACKGROUND:-}" ]; then
        printf "%b\n" "${BLDCYN}[pull job in background]${BLDRST}"
        git pull --no-edit "$@" &
      fi
    else
        ## Discard local changes and use latest from remote ##
        printf "%b\n" "${BLDWHT}[git reset --hard $REMOTE/$BRANCH]${BLDRST}" 2>&1
        git reset --hard "${REMOTE}"/"${BRANCH}" || { printf "%b\n" "${BLDRED}[reset failed]${BLDRST}" ; exit 1; }
        git pull --no-edit origin "$GIT_BRANCH"
        git submodule update --init --recursive
        printf "%b\n" "${BLDGRN}[git log --oneline --reverse --format=" - %s" v${OLD_TAG}]${BLDRST}"

    fi
}

disable_armor() {
    printf "%b\n" "${BLDWHT}[Disabling apparmor for database installation]${BLDRST}"
    sudo service apparmor stop
    sudo update-rc.d -f apparmor remove
    exit 0
}

upload_packg() {
  local ARCHIVE_FILENAME="${1}"
  local PACKAGE_URL="${2}"
  local TOKEN_HEADER="${CURL_TOKEN_HEADER}"
  local TOKEN="${CI_JOB_TOKEN}"

  if [[ "${UPLOAD_PACKAGE_FLAG}" = "false" ]]; then
    echo "The archive ${ARCHIVE_FILENAME} isn't supposed to be uploaded for this instance.\n"
    printf "%b\n" "${BLDWHT}[({CI_SERVER_HOST}) & project (${CI_PROJECT_PATH})!]${BLDRST}"
    exit 1
  fi

  printf "%b\n" "${BLDCYN}["Uploading ${ARCHIVE_FILENAME} to ${PACKAGE_URL} ..."]${BLDRST}"
  curl --fail --silent --retry 3 --header "${TOKEN_HEADER}: ${TOKEN}" --upload-file "${ARCHIVE_FILENAME}" "${PACKAGE_URL}"
}


