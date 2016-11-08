#!/bin/bash
script_path=$(cd `dirname $0` && pwd -P)
cd $script_path
cd ..
pwd -P
gitbook install
gitbook build
git checkout gh-pages
cp -rf _book/ ./
