if [ "$1" = "sed" ];
then
    if sed "2d" $2 | sed "2 i Exec=$HOME/.autoproxy/auto_proxy.sh" > $3;
    then
        echo "SUCCESS"
    else
        echo "FAIL"
    fi
elif [ "$1" = "rm" ];
then
    if rm -f $2;
    then
        echo "SUCCESS"
    else
        echo "FAIL"
    fi
fi
# echo $1 | sudo -S cp $2 $3
