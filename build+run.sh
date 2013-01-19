#!/bin/bash
~/bin/tool.sh Jael.g
~/bin/cantlr.sh *java
~/bin/rantlr.sh CallGraph $@

