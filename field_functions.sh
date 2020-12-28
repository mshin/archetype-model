#!/bin/bash

declare -a type_arr field_arr
# $1 fields
get_fields_and_types () {
    type_st=$(sed "s/:.*$//" <<< "${1}")
    field_st=$(sed "s/^.*://" <<< "${1}")
    type_arr=(${type_st//$'\n'/ })
    field_arr=(${field_st//$'\n'/ })
}

create_field_string () {
    out=""
    # replace colon with \s
    out=${1//:/ }
    # add '    private ' to the beginning of each line
    out=$(sed "s/^/    private /" <<< "${out}")
    # add semicolon to the end of each line
    out=$(sed "s/$/;/" <<< "${out}")
    echo "${out}"
    out=""
}

# $1 field_string
create_field_string_with_annotations () {
    output=""
    k=0
    while IFS="" read -r p || [ -n "$p" ]
    do
        output+="&%${field_arr[$k]}&%^"
        output+="${p}^^"
        ((k++))
    done <<< "${1}"
    echo "${output}"
    output=""
}