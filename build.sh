#!/bin/bash

rm -rf cmake-build-debug

cmake -H. -Bcmake-build-debug -DCMAKE_BUILD_TYPE=Debug
cmake --build cmake-build-debug --target mp4demuxer -- -j 6 
