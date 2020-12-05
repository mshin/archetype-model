#!/bin/bash

# archetype gav
G=''
A=''
V=''

# generated project's gav
g=''
a=''
v=''

usage="
Usage: required: -G -A -V for the archetype, -g -a for the project generated.
Usage: optional: -v for the generated project's version.
"

print_usage() {
  echo "$usage";
}

while getopts 'G:A:V:g:a:v:' flag; do
  case "${flag}" in
    G) G="${OPTARG}" ;;
    A) A="${OPTARG}" ;;
    V) V="${OPTARG}" ;;
    g) g="${OPTARG}" ;;
    a) a="${OPTARG}" ;;
    v) v="${OPTARG}" ;;
    *) print_usage
       exit 1 ;;
  esac
done

if [[ -z "$G" ]] || [[ -z "$A" ]] || [[ -z "$V" ]] || \
    [[ -z "$g" ]] || [[ -z "$a" ]]; then
  echo "$usage";
  exit 1;
fi

vv=''
if [[ -n "$v" ]]; then
  vv="-Dversion=";
fi

mvn archetype:generate               \
  -DarchetypeGroupId="$G"            \
  -DarchetypeArtifactId="$A"         \
  -DarchetypeVersion="$V"            \
  -DgroupId="$g"                     \
  -DartifactId="$a"                  \
  -Dpackage="$g.${a//-/.}"           \
  $vv$v

exit 0;