#!/usr/bin/env bash

# wait for overmind to quit
overmind quit > /dev/null 2>&1
while overmind status >/dev/null 2>&1; do
  sleep 1
done 

# convert output from command in array by splitting on newline
IFS=$'\n' read -d '' -r -a codespaces <  <(gh cs list --jq '.[] | select(.state == "Available")' --json state,displayName,name | jq -cMr '.displayName,.name' | sed 's/ /-/g')

# empty file .Procfile
echo -n "" > .Procfile

# for each item in codespaces add a line to .Procfile
for ((i=0; i<${#codespaces[@]}; i+=2)); do
  codespaceName="${codespaces[$i]}"
  codespace="${codespaces[$i+1]}"
  echo "$codespaceName: gh cs ssh -c $codespace -- -R 8888:localhost:8888" >> .Procfile
done

# start overmind to forward ports
cat .Procfile
overmind s -f .Procfile --any-can-die -D > /dev/null