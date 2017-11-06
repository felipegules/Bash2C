#/bin/bash


read x
y=5


for ((i=0;i<=10;i++))
do
    echo "estou no for"
done


function hello {
    echo "Funcao Hello"
    (( y = x / 2 ))
    echo $y
}

COUNTER=20
    
until [ $COUNTER -lt 10 ]
do
    echo $COUNTER
    (( COUNTER-- ))
done

while [ $x -le 10 ]
do
    if [ $x -le 2 ] ; then
        (( y = y - 1 ))
        echo "entrou no if"
    elif [ $x -ge 5 ] ; then
        echo "entrou no elif"
        (( y = y - 1 ))
    else
        echo "entrou no else"
    fi
    (( x++ ))
done


hello
    

echo "Switch case, (1) case simples, (2) case | case, qualquer outro numero, DEFAULT "
read DISTR

case $DISTR in
    1)
        echo "Case Simples."
        ;;
    2|3)
        echo "case | case)"
        ;;
    *)
        echo "Default."
        ;;
esac

