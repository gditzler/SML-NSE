#!/usr/bin/env bash 

for file in `find *.eps`; do 
  echo "Converting ${file}"
  epstopdf ${file};
done
