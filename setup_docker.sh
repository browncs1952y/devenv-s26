#! /bin/bash

cd "$(dirname "$0")" || exit

if [ -d ../Ripes ]; then
    echo "Directory ../Ripes ($(realpath ../Ripes)) already exists. Please save your work and delete it before running this script"
    exit
fi

if [ -d ../gem5 ]; then
    echo "Directory ../gem5 ($(realpath ../gem5)) already exists. Please save your work and delete it before running this script"
    exit
fi

arch="$(uname -m)"
image="ghcr.io/browncs1952y/cs1952y-devenv"
tag=

if [[ $# -gt 0 ]]; then
    if [ "$1" = "--x86" ]; then
        tag="x64-latest"
    elif [ "$1" = "--arm" ]; then
        tag="arm65-latest"
    else
        echo "Argument $1 unrecognized. Must be either --x86 or --arm (or nothing to default to system architecture)"
        exit 1
    fi
else
    if [ "$arch" = "arm64" ] || [ "$arch" = "$aarch64" ]; then
        tag="arm64-latest"
    elif [ "$arch" = "x86_64" ] || [ "$arch" = "x86_64h" ] || [ "$arch" = "amd64" ]; then
        tag="x86_64-latest"
    else
        echo "Unable to recognize architecture $arch."
        echo "If you know you are on an x86_64 architecture (Intel or AMD machines), run this script with the --x86 flag"
        echo "If you know you are on an arm64 architecture (Apple Silicon), run this script with the --arm flag"
        echo "e.g. ./pull_docker.sh --x86 OR ./pull_docker.sh --arm"
        exit 1
    fi
fi

echo "Pulling image $image:$tag"
docker pull "$image:$tag" || (echo "Error pulling image. Please contact course staff." && exit)
docker tag "$image:$tag" "cs1952y:latest" || exit

echo "Starting docker container to copy over directories"
cname="cs1952y-container-temp"
docker run -d --name "$cname" "$image:$tag" || exit

echo "Copying over Ripes directory"
docker cp "$cname:/home/cs1952y-user/Ripes" ../Ripes || exit

echo "Copying over gem5 directory"
docker cp "$cname:/home/cs1952y-user/gem5" ../gem5 || exit

docker stop "$cname"
docker rm "$cname"

echo "SUCESS!"

echo "Your work will now be saved locally in the ../Ripes and ../gem5 directories."
echo "We recommend configuring the git URLs of these directories to your own copy, e.g."
echo "cd ../Ripes"
echo "git remote set-url origin NEW_URL"
echo "where NEW_URL is the URL of your personal Ripes repository"
