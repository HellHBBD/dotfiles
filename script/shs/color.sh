#!/bin/bash
for i in {0..7}; do
  echo "$(tput setab $i)setab $i$(tput sgr0)\
  $(tput setb $i)setb $i$(tput sgr0)\
  $(tput setaf $i)setaf $i$(tput sgr0)\
  $(tput setf $i)setf $i$(tput sgr0)"
done

for i in {90..97}; do
  echo "$(tput setab $i)setab $i$(tput sgr0)\
  $(tput setb $i)setb $i$(tput sgr0)\
  $(tput setaf $i)setaf $i$(tput sgr0)\
  $(tput setf $i)setf $i$(tput sgr0)"
done
