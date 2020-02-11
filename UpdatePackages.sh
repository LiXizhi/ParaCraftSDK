#!/bin/bash
# author: lixizhi@yeah.net
# date: 2019.7.25


# param1 is folder name
# param2 is github url
function InstallPackage()
{
    if [ -f "$1/README.md" ]; then
        pushd $1
        git reset --hard
        git pull
        popd
    else
        rm -rf "./$1"
        git clone $2
    fi
}

if [ ! -d npl_packages ]; then 
    mkdir npl_packages 
fi

pushd npl_packages

InstallPackage paracraft https://github.com/NPLPackages/paracraft
InstallPackage main https://github.com/NPLPackages/main

popd