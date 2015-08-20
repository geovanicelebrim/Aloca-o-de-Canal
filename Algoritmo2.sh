echo "---Algoritmo 2 (Desconsiderando o Ruido)----" >> log.txt
echo "$(date)" >> log.txt
vetCanais="$(wl channels)"
vetCanais=$(echo $vetCanais | tr " ")
vetUso=""
vetRuido=""
vetNivel=""

#Obtém o uso do canal atual------------------------------------
vetCanalAtual="$(wl channel)"
vetCanalAtual=$(echo $vetCanalAtual | tr " ")
for c in $vetCanalAtual
do
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
	
	#Obtem ocupação dos canais
	for c in $vetCanais
	do
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
		echo "Canal ${c}     Ocupação ${ocupacao}."
		echo "Canal ${c}     Ocupação ${ocupacao}." >> log.txt
	done

	#Calcula o melhor canal.-------------------------------------

	cont=0
	eleito=1
	ocupacaoAux=256

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
	fi

	#Fim--------------------------------------------------------------------------
fi
echo "Canal anterior: ${canalAtual}. Novo canal: ${eleito}."
echo "Canal anterior: ${canalAtual}. Novo canal: ${eleito}." >> log.txt
echo "--------------------------------------------" >> log.txt
