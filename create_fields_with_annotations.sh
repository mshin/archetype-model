#!/bin/bash

source ${0%/*}/functions.sh

fields=$1
pk_field=$2

declare -a type_arr field_arr
# $1 fields
get_fields_and_types () {
    type_st=$(sed "s/:.*$//" <<< "${1}")
    field_st=$(sed "s/^.*://" <<< "${1}")
    type_arr=(${type_st//$'\n'/ })
    field_arr=(${field_st//$'\n'/ })
}

declare field_string
create_field_string () {
    field_string=""
    # replace colon with \s
    field_string=${1//:/ }
    # add '    private ' to the beginning of each line
    field_string=$(sed "s/^/    private /" <<< "${field_string}")
    # add semicolon to the end of each line
    field_string=$(sed "s/$/;/" <<< "${field_string}")
    echo "${field_string}"
    field_string=""
}

create_field_string_with_annotations () {
    output=""
    k=0
    while IFS="" read -r p || [ -n "$p" ]
    do
        output+="&%${field_arr[$k]}&%^"
        output+="${p}^^"
        ((k++))
    done <<< "${field_string}"
    field_string="${output}"
}

# $1=Type $2=fieldName $3=type.properties $4=pk
build_column_annotation () {
    field_sql_case=$(convert_camel_to_sql_case "$2")
    prop_key=""
    replacement_string=""
    # if the annotation is a primary key, use that one, otherwise try to find it.
    if [[ "$2" = "$4" ]]; then
        prop_key="pk"
        replacement_string="${table_name_sql_case}"
    else 
        prop_key="$1"
        replacement_string="${field_sql_case}"
    fi
    # get annotation value out of properties file
    annotation=$(grep "${prop_key}=" "$3"  | cut -f2- -d'=')
    # if no annotation entry for Type in properties file, use default annotation
    if [[ -z "${annotation}" ]]; then
        annotation="    @Column( name = \"%\" )"
    fi
    # replace the annotation placeholder for the field with the annotation.
    annotation="${annotation//\%/${replacement_string}}"
    echo "${annotation}"
    annotation=""
}

get_fields_and_types "${fields}"

field_string=$(create_field_string "${fields}")

create_field_string_with_annotations "${field_string}"

# replace all the annotation placeholders with the real annotations
for (( j=0; j<"${#field_arr[@]}"; j++ ))
do
    ann=$(build_column_annotation ${type_arr[j]} ${field_arr[j]} ${0%/*}/jpa_type_annotation.properties ${pk_field})
    field_string="${field_string/&\%${field_arr[j]}&\%/${ann}}"
done

echo "${field_string}"
