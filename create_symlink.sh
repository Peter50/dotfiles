#!/bin/bash

mkdir ~/.dotfile.old
mv .bashrc .bash_logout ~/.dotfile.old/

for i in $(find "$(pwd)" -type f | grep -v ".git" | grep -v $0 | grep -v README); do
	ln -s -t ~ $i
done
