echo "-----Algoritmo 1 (Considerando o Ruido)-----" >> log.txt
echo "$(date)" >> log.txt
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
tolerancia=1

if [ $ocupacaoAtual -lt $tolerancia ]
then
	echo "Ocupação dentro da tolerância."
	echo "Ocupação dentro da tolerância." >> log.txt
fi

echo "Canal atual: ${canalAtual}."
echo "Ocupação: ${ocupacaoAtual}."
echo "Tolerância: ${tolerancia}."
echo "Canal atual: ${canalAtual}." >> log.txt
echo "Ocupação: ${ocupacaoAtual}." >> log.txt
echo "Tolerância: ${tolerancia}." >> log.txt

if [ $tolerancia -lt $ocupacaoAtual ]
then
	echo "Ocupação fora da tolerância."
	echo "Ocupação fora da tolerância." >> log.txt

	#Obtem ocupação e o ruido de todos os canais---------------
	for c in $vetCanais; do
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
		echo "Canal ${c}     Ocupação ${ocupacao}     Ruído ${ruido}."
		echo "Canal ${c}     Ocupação ${ocupacao}     Ruído ${ruido}." >> log.txt
	done


	#Calcula o melhor canal.-------------------------------------

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
	fi

	#Fim--------------------------------------------------------------------------
fi
echo "Canal anterior: ${canalAtual}. Novo canal: ${melhorCanal}."
echo "Canal anterior: ${canalAtual}. Novo canal: ${melhorCanal}." >> log.txt
echo "--------------------------------------------" >> log.txt
