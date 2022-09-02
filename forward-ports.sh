#!/usr/bin/env bash

# wait for overmind to quit
overmind quit > /dev/null 2>&1
while overmind status >/dev/null 2>&1; do
  sleep 1
done 

# convert output from command in array by splitting on newline
IFS=$'\n' read -d '' -r -a codespaces <  <(gh cs list --jq '.[] | select(.state == "Available")' --json state,name | jq -cMr '.name' && printf '\0')
# read -r -a codespaces <<< "$(gh cs list --jq '.[] | select(.state == "Available")' --json state,name | jq -cMr '.name')"

# empty file .Procfile
echo -n "" > .Procfile

# for each item in codespaces add a line to .Procfile
for codespace in "${codespaces[@]}"; do
  echo "$codespace: gh cs ssh -c $codespace -- -R 8888:localhost:8888" >> .Procfile
done

# start overmind to forward ports
# overmind s -f .Procfile --any-can-die -D -r "$(IFS=, ; echo "${codespaces[*]}")"
cat .Procfile
overmind s -f .Procfile --any-can-die -D > /dev/null