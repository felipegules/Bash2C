#/bin/bash

read x
y=5
@
while [ $x -le 10 ]
do
    if { $x -le 2 } ; then
        (( y = y - 1 ))
        echo "entrou no IF"
    elif [ $x -ge 5 ] ; then
        echo "entrou no elif"
        (( y = y - 1 ))
    else
        echo "entrou no else"
    fi
    (( x++ ))
done
while

(( y = x / 2 ))
echo $y
echo $x

