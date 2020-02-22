#!/usr/bin/env bash
# Copyright © 2019 Maestro Creativescape
#
# SPDX-License-Identifier: GPL-3.0
#
### Script to test and format our jsons

validate_arg() {
    valid=$(echo $1 | sed s'/^[\-][a-z0-9A-Z\-]*/valid/'g)
    [ "x$1" == "x$0" ] && return 0;
    [ "x$1" == "x" ] && return 0;
    [ "$valid" == "valid" ] && return 0 || return 1;
}

print_help() {
    echo "Usage: `basename $0` [OPTION]";
    echo "  -s, --string \ Supply String to kang" ;
    echo "  -F, --newpath \ Supply Old File Path, (root dir of res)" ;
    echo "  -f, --source \ Source Path, (root dir of res)" ;
}

prev_arg=
while [ "$1" != "" ]; do
    cur_arg=$1

    # find arguments of the form --arg=val and split to --arg val
    if [ -n "`echo $cur_arg | grep -o =`" ]; then
        cur_arg=`echo $1 | cut -d'=' -f 1`
        next_arg=`echo $1 | cut -d'=' -f 2`
    else
        cur_arg=$1
        next_arg=$2
    fi

    case $cur_arg in

        -s | --string )
            string_to_kang=$next_arg
            ;;
        -f | --source )
            source_path=$next_arg
            ;;
        -F | --newpath )
            kang_path=$next_arg
            ;;
        *)
            validate_arg $cur_arg;
            if [ $? -eq 0 ]; then
                echo "Unrecognised option $cur_arg passed"
                print_help
            else
                validate_arg $prev_arg
                if [ $? -eq 1 ]; then
                    echo "Argument $cur_arg passed without flag option"
                    print_help
                fi
            fi
            ;;
    esac
    prev_arg=$1
    shift
done

if [ -z "$string_to_kang" ] || [ -z "$source_path" ] || [ -z "$kang_path" ]; then
    print_help
    exit 1
fi

string_to_kang="<string name=\"$string_to_kang\""



for i in $(find ${source_path} -name "values-*")
do
if [ -f $i/strings.xml ]; then
    stringxxx=$(cat $i/strings.xml | grep "$string_to_kang")
    paths="$i/strings.xml"
    folder_name=$(echo "$paths" | cut -d / -f 3)
    mkdir -p $kang_path/$folder_name
    echo $stringxxx
    if [ -n "$stringxxx" ]; then 
    if [ ! -f $kang_path/$folder_name/strings.xml ]; then
       cat android_header > $kang_path/$folder_name/strings.xml
    else
       sed -i "s/<\/resources>//g" "$kang_path/$folder_name/strings.xml"
    fi
    echo $stringxxx >> $kang_path/$folder_name/strings.xml
    echo -n "</resources>" >> $kang_path/$folder_name/strings.xml
    fi
fi
done