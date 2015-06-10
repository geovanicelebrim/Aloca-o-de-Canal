vetCanais="$(wl channels)"
vetCanais=$(echo $vetCanais | tr " ")
vetUso=""

#Só é possível obter o ruido do canal atual.
vetRuido="$(wl noise)"

#Obtem medidas de dos canais-----------------------------------
for c in $vetCanais; do
	
	#Mostra o canal que está sendo analizado
	echo "Analizando canal ${c}"

	#Obtem uso do canal
	wl rm_req cca -c $c -d 50
	sleep 1
	logSystem="$(wl rm_rep)"
	logSystem=$(echo $logSystem | tr ":""\n")

	cont=0
	for x in $logSystem
	do
		cont=$(($cont+1))
		if test $cont = 29
		then
			clear
			ocupacao=$x
			vetUso="${vetUso} ${ocupacao}"
		fi
	done
	clear

	#Informa a ocupação do canal analizado.
	echo "Ocupação: ${ocupacao} de 255."
	echo "Mensagem completa: "
	wl rm_rep

	sleep 1
done

#Fim---------------------------------------------------------

#Calcula o melhor canal."Por enquanto só se baseando no uso, pois o ruido é obtido só do atual canal."------

clear
cont=0
menorUso=256

for c in $vetUso
do
	cont=$(($cont+1))
	echo "Canal ${cont}, ocupação ${c}"
	
	if [ "$c" -lt "$menorUso" ]
	then
		menorUso=$c
		melhorCanal=$cont
	fi
done

echo "Melhor canal: ${melhorCanal} Uso: ${menorUso}"

#Fim--------------------------------------------------------------------------------------------------------

#Altera o canal. "Alterar o canal implica em reiniciar o roteador, o que faz com que os dispositivos tenham que reconectar."-

wl down
wl channel 6
wl up

#Fim-------------------------------------------------------------------------------------------------------------------------