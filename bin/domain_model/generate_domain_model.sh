#!/bin/bash

# $1: yaml descriptor path; $2 document number

dir=${0%/*}
source ${dir}/../common_scripts/functions.sh
source ${dir}/../common_scripts/field_functions.sh


# for each document in the yaml file
 # generate the maven project (build existing java file url.)
 # create new models based on template
  # create the file in same directory as other file.
  # replace the .java file name with model name
  # replace the fields with a new field string
  # TODO update imports for fields.
 # delete placeholder model

declare g a
generate_maven_project $1 $2 g a

model_path=${a}/src/main/java/${g//./\/}/${a//-/\/}

class_content=$(<$model_path/class0.java)

num_models=$(yq r -d$2 $1 "model" -l)


for (( i=0; i<${num_models}; i++ ))
do
    # create java class at template location
    model_name=$(yq r -d$2 $1 "model[${i}].name")
    model_path_name=${model_path}/${model_name}.java
    echo "model_name${i}: ${model_name}"

    cp ${model_path}/class0.java "$model_path_name"

    # set the class name in the file to the correct value.
    sed -i.bak "s/class0/${model_name}/" "${model_path_name}" && rm "${model_path_name}.bak"

    # replace fields with generated fields.
    fields=$(yq r -d$2 $1 "model[${i}].fields[*]")
    get_fields_and_types "${fields}"
    field_string=$(create_field_string "false")

    #replace newline with carrots in field_string because sed has problem processing \n
    field_string=${field_string//$'\n'/^}

    # replace fields placeholder in java class with actual fields with ^
    sed -i.bak "s/^    fields/${field_string}/" "${model_path_name}" && rm "${model_path_name}.bak"

    # use tr (translate) command to replace carrot with newline in java file.
    tr ^ '\n' < "${model_path_name}" > "${model_path}/temp.java" && mv "${model_path}/temp.java" "${model_path_name}"

done

# delete placeholder model
rm ${model_path}/class0.java

# call formatter on project
beautify_imports "$a" "${model_path}"

mvn clean install -f $a/pom.xml

exit 0
