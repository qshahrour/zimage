#!/bin/bash
##############
set +e

if [ ! -f "Dockerfile" ]; then
    echo "Dockerfile is missing!"
    exit 1
fi
####################################
OS=${PWD##*/}
VERSION=${1:-latest}
TYPE=${2:-build}

app_component=$(cd ../ && echo "${PWD##*/}")

if [ "$app_component" == "zabbix-appliance" ]; then
    app_component="appliance"
fi

if [[ ! $VERSION =~ ^[0-9]*\.[0-9]*\.[0-9]*$ ]] && [ "$VERSION" != "latest" ]; then
    echo "Incorrect syntax of the version"
    exit 1
fi
####################################
if [ "$VERSION" != "latest" ]; then
    VCS_REF=$(git ls-remote https://git.zabbix.com/scm/zbx/zabbix.git refs/tags/"$VERSION" | cut -c1-10)
else
    MAJOR_VERSION=$(grep "ARG MAJOR_VERSION" Dockerfile | head -n1 | cut -f2 -d"=")
    MINOR_VERSION=$(grep "ARG ZBX_VERSION" Dockerfile | head -n1 | cut -f2 -d".")

    VCS_REF=$MAJOR_VERSION.$MINOR_VERSION
fi
####################################
if hash docker 2>/dev/null; then
    EXEC_COMMAND='docker'
elif hash podman 2>/dev/null; then
    EXEC_COMMAND='podman'
else
    echo >&2 "Build command requires docker or podman.  Aborting."
    exit 1
fi
####################################
DOCKER_BUILDKIT=1 $EXEC_COMMAND build -t "zabbix-$app_component:$OS-$VERSION" --build-arg VCS_REF="$VCS_REF" --build-arg BUILD_DATE="$( date -u +"%Y-%m-%dT%H:%M:%SZ" )" -f Dockerfile .

if [ "$TYPE" != "build" ]; then
    links=""
    env_vars=""

    if [[ $app_component =~ .*mysql.* ]]; then
        links="$links --link mysql-server:mysql"
        env_vars=("$env_vars" -e MYSQL_DATABASE="zabbix" -e MYSQL_USER="zabbix" -e MYSQL_PASSWORD="zabbix" -e MYSQL_RANDOM_ROOT_PASSWORD=true)

        $EXEC_COMMAND rm -f mysql-server
        $EXEC_COMMAND run --name mysql-server -t "${env_vars[@]}" -d mysql:8.0-oracle
    fi

    if [ "$links" != "" ]; then
        sleep 5
    fi

    $EXEC_COMMAND rm -f zabbix-"$app_component"

    $EXEC_COMMAND run --name zabbix-"$app_component" -t -d "$links" "${env_vars[@]}" "zabbix-$app_component:$OS-$VERSION"
fi
####################################
