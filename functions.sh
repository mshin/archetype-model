#!/bin/bash

# $1=camelcase variable
convert_camel_to_sql_case () {
    # convert camel to snake case
    sql_case=$(sed -E "s/([A-Z]+)/_\1/g" <<< "${1}")
    # set all lowercase to uppercase
    sql_case=$(tr '[:lower:]' '[:upper:]' <<< "${sql_case}")
    # remove any leading underscores
    sql_case=${sql_case#_}
    echo "${sql_case}"
    sql_case=""
}

# $1 string that you want to make the first letter lowercase
lower_first () {
    output=""
    output=$(echo ${1:0:1} | tr '[A-Z]' '[a-z]')${1:1}
    echo "${output}"
    output=""
}

# $1 yaml proj descriptor location; $2 doc num index 0; $3 g callback $4 a callback
generate_maven_project () {
    GAV_string=$(yq r -d$2 $1 "archetypeGAV")
    GAV_arr=(${GAV_string//:/ })
    gav_string=$(yq r -d$2 $1 "generatedGav")
    gav_arr=(${gav_string//:/ })
    author=$(yq r -d$2 $1 "author")

    local groupId artifiactId
    groupId=${gav_arr[0]}
    artifiactId=${gav_arr[1]}
    v=${gav_arr[2]}
    p=$groupId.${artifiactId//-/.}

    eval "${3}=${groupId} ${4}=${artifiactId}"

    # handle user not giving a version number
    vv=''
    if [[ -n "$v" ]]; then
      vv="-Dversion=";
    fi

    mvn archetype:generate                     \
      -DarchetypeGroupId="${GAV_arr[0]}"       \
      -DarchetypeArtifactId="${GAV_arr[1]}"    \
      -DarchetypeVersion="${GAV_arr[2]}"       \
      -DgroupId="${groupId}"                           \
      -DartifactId="${artifiactId}"                        \
      -Dpackage="$groupId.${artifiactId//-/.}"                 \
      -Dclass0="class0"                        \
      -Dfields="fields"                        \
      -Dauthor="$author"                       \
      -B                                       \
      $vv$v
}
