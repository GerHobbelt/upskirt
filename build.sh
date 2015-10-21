#!/bin/bash

mkdir -p "build"

# Compile src/html_entities.gperf

gperf src/html_entities.gperf > build/html_entities.c

# Build Snudown

files="snudown.c src/autolink.c src/buffer.c src/markdown.c src/stack.c html/houdini_href_e.c html/houdini_html_e.c html/html.c build/html_entities.c"
include=("src" "html")
exported=("default_renderer" "wiki_renderer" "snudown_md" "version" "main")
options=("NO_EXIT_RUNTIME=1" "NO_FILESYSTEM=1" "NO_BROWSER=1" "NO_DYNAMIC_EXECUTION=1")

if [ "$1" = "-d" ] || [ "$1" = "--debug" ]; then
	optimization=""
else
	echo "*** DEBUGGING OFF : use -d to enable ***"
	optimization="-O3 --memory-init-file 0"
fi

cmd="emcc $files -o build/snudowncore.js $optimization"

for i in "${options[@]}"; do
	cmd="$cmd -s $i"
done

for i in "${include[@]}"; do
	cmd="$cmd -I$i"
done

cmd="$cmd -s EXPORTED_FUNCTIONS=["

for i in "${exported[@]}"; do
	cmd="$cmd'_$i',"
done

cmd="${cmd:0:${#cmd} - 1}" # trim last comma
cmd="$cmd]"

$cmd

# Build snudown-js

./node_modules/gulp/bin/gulp.js build

rm -r "build"