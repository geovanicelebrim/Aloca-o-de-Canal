vetCanais="$(wl channels)"
vetCanais=$(echo $vetCanais | tr " ")
vetUso=""
vetRuido=""
vetNivel=""

#Obtém o uso do canal atual------------------------------------
vetCanalAtual="$(wl channel)"
vetCanalAtual=$(echo $vetCanalAtual | tr " ")
for c in $vetCanalAtual; do
	canalAtual=$c
done

wl rm_req cca -c $canalAtual -d 50
sleep 1
logSystem="$(wl rm_rep)"
logSystem=$(echo $logSystem | tr ":""\n")

cont=0
for x in $logSystem
do
	cont=$(($cont+1))
	if test $cont = 29
	then
		ocupacaoAtual=$x
	fi
done
#--------------------------------------------------------------

#Verifica se a ocupação está dentro da tolerância--------------
clear
tolerancia=1

if [ $tolerancia -lt $ocupacaoAtual ]
then
	
	#Obtem ocupação dos canais
	for c in $vetCanais; do
		clear
		echo "Analisando canal ${c}"
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
				ocupacao=$x
				vetUso="${vetUso} ${ocupacao}"
			fi
		done
		clear
	done

	#Calcula o melhor canal.-------------------------------------

	clear
	cont=0
	eleito=1
	ocupacaoAux=256
	#Seleciona os canais canditados.
	for c in $vetUso
	do
		cont=$(($cont+1))
		
		if [ $c -lt $ocupacaoAux ]
		then
			eleito=$cont
			ocupacaoAux=$c
		fi
	done

	#Altera o canal---------------------------------------------------------------
	if test $canalAtual != $eleito
	then
		wl down;	wl channel $eleito;	wl up;
		echo "Canal anterior: ${canalAtual}. Novo canal: ${eleito}."
	fi

	#Fim--------------------------------------------------------------------------
fi
