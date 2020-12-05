#!/bin/bash

# Usage: ../code/archetype-model/archetype-domain-model/src/main/bin/generate_domain_model.sh -g com.mycompany -a my-model

dir=${0%/*};

# generated project's gav
g=''
a=''
v=''

usage="
Usage: required: -g -a for the project generated.
Usage: optional: -v for the generated project's version
"

print_usage() {
  echo "$usage";
}

while getopts 'g:a:v:' flag; do
  case "${flag}" in
    g) g="${OPTARG}" ;;
    a) a="${OPTARG}" ;;
    v) v="${OPTARG}" ;;
    *) print_usage
       exit 1 ;;
  esac
done

$dir/generate.sh -G com.github.mshin -A archetype-domain-model -V 0.0.1 -g "$g" -a "$a" -v "$v"

exit 0;