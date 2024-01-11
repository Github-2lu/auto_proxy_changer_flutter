if [ "$1" = "cp" ];
then
    if echo $2 | sudo -k -S cp $3 $4;
    then
        echo "SUCCESS"
    else
        echo "FAIL"
    fi
elif [ "$1" = "rm" ];
then
    if echo $2 | sudo -k -S rm -f $3;
    then
        echo "SUCCESS"
    else
        echo "FAIL"
    fi
fi
# echo $1 | sudo -S cp $2 $3
