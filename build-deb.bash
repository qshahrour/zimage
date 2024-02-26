#!/usr/bin/env bash
# =================
set -x
set -e

debDate="$( date --rfc-2822 )"
# untar sources
mkdir -p /root/build-deb/engine
tar -C /root/build-deb -xzf /sources/engine.tgz
mkdir -p /root/build-deb/cli
tar -C /root/build-deb -xzf /sources/cli.tgz
mkdir -p /root/build-deb/buildx
tar -C /root/build-deb -xzf /sources/buildx.tgz
mkdir -p /root/build-deb/compose
tar -C /root/build-deb -xzf /sources/compose.tgz

EPOCH="${EPOCH:-}"
EPOCH_SEP=""
if [[ ! -z "${EPOCH}" ]]; then
  EPOCH_SEP=":"
fi

if [[ -z "${DEB_VERSION}" ]]; then
 echo "DEB_VERSION is required to build deb packages"
 exit 1
fi

echo VERSION AAA "${VERSION}"

VERSION=${VERSION:-$( cat cli/VERSION )}

echo VERSION bbb "${VERSION}"

debSource="$( awk -F ': ' '$1 == "Source" { print $2; exit }' debian/control )"
debMaintainer="$( awk -F ': ' '$1 == "Maintainer" { print $2; exit }' debian/control )"
debDate="$( date --rfc-2822 )"

# Include an extra `1` in the version, in case we ever would have to re-build an
# already published release with a packaging-only change.
pkgRevision=1

# Generate changelog. The version/name of the generated packages are based on this.
# shellcheck disable=SC1017
#
# Resulting packages are formatted as;
#
# - name of the package (e.g., "docker-ce")
# - version (e.g., "23.0.0~beta.0")
# - pkgRevision (usually "-0", see above), which allows updating packages with
#   packaging-only changes (without a corresponding release of the software
#   that's packaged).
# - distro (e.g., "ubuntu")
# - VERSION_ID (e.g. "22.04" or "11") this must be "sortable" to make sure that
#   packages are upgraded when upgrading to a newer distro version ("codename"
#   cannot be used for this, as they're not sorted)
# - SUITE ("codename"), e.g. "jammy" or "bullseye". This is mostly for convenience,
#   because some places refer to distro versions by codename, others by version.
#   we prefix the codename with a tilde (~), which effectively excludes it from
#   version comparison.
#
# Note that while the `${EPOCH}${EPOCH_SEP}` is part of the version, it is not
# included in the package's *filename*. (And if you're wondering: we needed the
# EPOCH because of our use of CalVer, which made version comparing not work in
# some cases).
#
# Examples:
#
# docker-ce_23.0.0~beta.0-1~debian.11~bullseye_amd64.deb
# docker-ce_23.0.0~beta.0-1~ubuntu.22.04~jammy_amd64.deb

cat > "debian/changelog" <<-EOF
$debSource ( ${EPOCH}${EPOCH_SEP}${DEB_VERSION}-${pkgRevision}~${DISTRO}.${VERSION_ID}~${SUITE} ) $SUITE; urgency=low
  * Version: $VERSION
-- $debMaintainer  $debDate
EOF
# The space above at the start of the line for the debMaintainer is very important
# Give the script a git commit because it wants it

export CLI_GITCOMMIT="${CLI_GITCOMMIT-$( cd cli; ${GIT_COMMAND}	D )}"
export ENGINE_GITCOMMIT="${ENGINE_GITCOMMIT-$( cd engine; ${GIT_COMMAND} rev-parse --short HEAD )}"

echo VERSION BBB "${VERSION}"
dpkg-buildpackage -uc -us -I.git
DESTINATION="/build"
mkdir -p "${DESTINATION}"
mv -v /root/docker* "${DESTINATION}"
# ========= End of Script ============= #






























