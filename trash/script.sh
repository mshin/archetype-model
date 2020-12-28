#!/bin/bash

create_imports_string () {
    
    field_arr=($1)
    for i in "${field_arr[@]}"
    do
        echo $i
    done
}

field_string=""
create_field_string () {

    # replace colon with \s
    field_string=${1//:/ }
    # add 'private ' to the beginning of each line
    field_string=$(sed "s/^/    private /" <<< "${field_string}")
    # add semicolon to the end of each line
    field_string=$(sed "s/$/;/" <<< "${field_string}")
}

declare g a p model_path
generate_maven_project () {
    GAV_string=$(yq r $1 "archetypeGAV")
    GAV_arr=(${GAV_string//:/ })
    gav_string=$(yq r $1 "generatedGav")
    gav_arr=(${gav_string//:/ })
    author=$(yq r $1 "author")

    g=${gav_arr[0]}
    a=${gav_arr[1]}
    v=${gav_arr[2]}
    p=$g.${a//-/.}

    # handle user not giving a version number
    vv=''
    if [[ -n "$v" ]]; then
      vv="-Dversion=";
    fi

    mvn archetype:generate                     \
      -DarchetypeGroupId="${GAV_arr[0]}"       \
      -DarchetypeArtifactId="${GAV_arr[1]}"    \
      -DarchetypeVersion="${GAV_arr[2]}"       \
      -DgroupId="$g"                           \
      -DartifactId="$a"                        \
      -Dpackage="$g.${a//-/.}"                 \
      -Dclass0="class0"                        \
      -Dfields="fields"                        \
      -Dauthor="$author"                       \
      -B                                       \
      $vv$v
}

# for each document in the yaml file
 # generate the maven project (build existing java file url.)
 # create new models based on template
  # create the file in same directory as other file.
  # replace the .java file name with model name
  # replace the fields with a new field string
  # TODO update imports for fields.
 # delete placeholder model

generate_maven_project $1

model_path=${a}/src/main/java/${g//./\/}/${a//-/\/}/

class_content=$(<$model_path/class0.java)

num_models=$(yq r $1 "model" -l)

for (( i=0; i<${num_models}; i++ ))
do
    # create java class at template location
    model_name=$(yq r $1 "model[${i}].name")
    model_path_name=${model_path}/${model_name}.java
    echo "model_name${i}: ${model_name}"

    cp ${model_path}/class0.java "$model_path_name"

    # set the class name in the file to the correct value.
    sed -i.bak "s/^public class class0/public class ${model_name}/" "${model_path_name}" && rm "${model_path_name}.bak"

    # replace fields with generated fields.
    fields=$(yq r $1 "model[${i}].fields[*]")

    create_field_string "${fields}"

    #replace newline with carrots in field_string because sed has problem processing \n
    field_string=${field_string//$'\n'/^}

    # replace fields placeholder in java class with actual fields with ^
    sed -i.bak "s/^    fields/${field_string}/" "${model_path_name}" && rm "${model_path_name}.bak"

    # use tr (translate) command to replace carrot with newline in java file.
    tr ^ '\n' < "${model_path_name}" > "${model_path}/temp.java" && mv "${model_path}/temp.java" "${model_path_name}"

done

# delete placeholder model
rm ${model_path}/class0.java

exit 0
