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
tolerancia=30

if [ $tolerancia -lt $ocupacaoAtual ]
then
	
	#Obtem ocupação e o ruido de todos os canais---------------
	for c in $vetCanais; do
		clear
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
				ocupacao=$x
				vetUso="${vetUso} ${ocupacao}"
			fi
		done
		clear

		#Obtém o ruido do canal
		wl rm_req rpi -c $c -d 50
		sleep 1
		logSystem="$(wl rm_rep)"
		logSystem=$(echo $logSystem | tr ":""\n")
		cont=0
		for x in $logSystem
		do
			cont=$(($cont+1))
			if test $cont = 30 || test $cont = 36 || test $cont = 42 || test $cont = 48 || test $cont = 54 || test $cont = 60 || test $cont = 66 || test $cont = 71
			then
				vetNivel="${vetNivel} ${x}"
			fi

			if test $cont = 71
			then
				aux=87
				ruido=0
				for k in $vetNivel; do
					ruido=$(($ruido+$aux*$k))
					aux=$(($aux-5))
				done
				ruido=$(($ruido/255))
				vetRuido="${vetRuido} ${ruido}"
				vetNivel=""
			fi

		done
	done


	#Calcula o melhor canal.-------------------------------------

	clear
	cont=0
	candidatos=""

	#Seleciona os canais canditados.
	for c in $vetUso
	do
		cont=$(($cont+1))
		
		if [ "$c" -lt "$ocupacaoAtual" ]
		then
			candidatos="${candidatos} ${cont}"
		fi
	done

	#Elege o canal de acordo com o ruído.
	eleito=1
	ruido=256
	melhorCanal=0

	for c in $candidatos
	do
		cont=0
		for x in $vetRuido
		do
			cont=$(($cont+1))
			if test $cont = $c
			then
				if [ "$x" -lt "$ruido" ]
				then
					ruido=$x
					melhorCanal=$cont
				fi

			fi
		done
	done
	#-----------------------------------------------------------------------------

	#Altera o canal---------------------------------------------------------------
	if test $canalAtual != $melhorCanal
	then
		wl down;	wl channel $melhorCanal;	wl up;
		echo "Canal anterior: ${canalAtual}. Novo canal: ${melhorCanal}."
	fi

	#Fim--------------------------------------------------------------------------
fi
