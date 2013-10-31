#!/bin/bash
~/bin/tool.sh Jael.g
~/bin/cantlr.sh Jael*java CallGraph.java
echo 'running with input:' $@
~/bin/rantlr.sh CallGraph $@

