#!/bin/bash

cd 01 && dd if=/dev/zero of=.backup bs=1048576 count=1024 1>/dev/null 2>&1

alias hint="cat .hint"
alias one-more-hint="cat .hint-2"
alias solution="cat .solution"
