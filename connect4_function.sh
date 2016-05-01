#!/bin/bash

# Menu de lancement
function Menu {
	clear
#	echo -e "\033[36m test \033[0m"
	echo " === CONNECT4 ==="
    echo
	echo " 1. Jouer en local"
	echo " 0. Quitter"
	echo
	read -p " Choix : " choix
}

# Permet de définir les joueurs
function Choix_pseudo {
	clear
	echo " - Pseudo des joueurs -"
	
    while [ -z "$pseudo1" ]; do ## Pour éviter un pseudo vide
        read -p " Joueur 1 : " pseudo1
    done
    
    while [ -z "$pseudo2" ]; do
        read -p " Joueur 2 : " pseudo2
    done
}

# Initialise la grille avant de le début de partie
function Initialiser_grille {
	for((i=0; i<6; i++)); do 
		grille[i]="_ _ _ _ _ _ _"
	done
}

# Affiche l'interface de jeu
function Interface {
	clear

	for((i=0; i<6; i++)); do 
		for((j=1; j<=7; j++)); do 
			if [ ${grille[i]:($j-1)*2:1} = "X" ]; then
				echo -ne "\033[31m\t${grille[i]:($j-1)*2:1}\033[0m"
			elif [ ${grille[i]:($j-1)*2:1} = "O" ]; then
				echo -ne "\033[33m\t${grille[i]:($j-1)*2:1}\033[0m"
			else
				echo -ne "\t${grille[i]:($j-1)*2:1}"
			fi
        done
        echo -e '\n'
	done
    
	for((i=1; i<=7; i++)); do 
		echo -ne "\t$i"
	done
    
    Place_texte 2 65 "=== Connect4 ==="
    Place_texte 3 69 "Coups n°$coups"
    
    Place_texte 5 66 "\033[31mX : $pseudo1\033[0m"
    Place_texte 6 66 "\033[33mO : $pseudo2\033[0m"
    
    if [[ $((coups%2)) = 1 ]]; then
        Place_texte 5 64 ">"
    else
        Place_texte 6 64 ">"
    fi 
    
    Place_texte 13 63 "(ctrl+c pour Quitter)"
}

# Executer un tour
function Jouer {
    test=1
    while [[ $test = 1 ]]; do
        colonne=
        while [[ ! $colonne =~ ^[[:digit:]]{1}$ ]] || [[ $colonne -lt 1 || $colonne -gt 7 ]]; do
            Interface
            read -p " $1, choissisez une colonne : " colonne
        done

        if [[ ${grille[0]:($colonne-1)*2:1} = "_" ]]; then
            Placement $colonne $2
            test=0
        fi
    done
}

# Appliquer le nouveau jeton
function Placement {

    # On prend la variable k pour eviter les interferences avec le i dans la fonction Interface
    for((k=0; k<6; k++)); do
        if [[ ${grille[$k]:($1-1)*2:1} = "_" ]]; then
            grille[$k]=${grille[$k]:0:($1-1)*2}$2${grille[$k]:(($1-1)*2)+1}
            if [ $k -gt 0 ]; then 
                grille[$k-1]=${grille[$k-1]:0:($1-1)*2}"_"${grille[$k-1]:(($1-1)*2)+1}
            fi
            sleep 0.15
            Interface      
        fi
    done
}

# Permet de placer des textes n'importe où sur la console
function Place_texte {
    
    # On memorise la position actuelle du curseur
    echo -e "\033[s"
    # On affiche le texte a la position specifiee
    echo -e "\033[${1};${2}H${3}"    
    # On revient a la position precedente
    echo -e "\033[u"
}

# Appelle les fonctions de victoire
function Condition_victoire {
    condition=0
    # Test Vertical
        if [ $condition -eq 0 ]; then Victoire_verticale $1 ; fi
    # Test Horizontal
        if [ $condition -eq 0 ]; then Victoire_horizontale $1 ; fi
    # Test Diagonaux
        if [ $condition -eq 0 ]; then Victoire_diagonale $1 ; fi
    # Test Partie nulle
        if [ $condition -eq 0 ]; then Victoire_nulle; fi
}

function Victoire_verticale {
    # Test Vertical
    for((j=1; j<7; j++)); do
        align_vert=0
        for((i=0; i<6; i++)); do 
            if [ ${grille[i]:($j-1)*2:1} = "$1" ]; then
                ((align_vert++))
            else
                align_vert=0
            fi
            
            if [ $align_vert -ge 4 ] && [ $1 = "X" ]; then 
                victoire=1
            elif [ $align_vert -ge 4 ] && [ $1 = "O" ]; then 
                victoire=2
            fi
        done
    done
}

function Victoire_horizontale {
    # Test Horizontal
    for((i=0; i<6; i++)); do 
        echo ${grille[i]} | grep "$1 $1 $1 $1" >/dev/null && condition=1
    done
    
    if [ $condition -eq 1 ] && [ $1 = "X" ]; then 
        victoire=1
    elif [ $condition -eq 1 ] && [ $1 = "O" ]; then 
        victoire=2
    fi
}

function Victoire_diagonale {
    # Test Diagonale Haut-Gauche vers Bas-Droite
    for ((i=0; i<=2; i++)); do
        for ((j=1; j<=7; j++)); do
            if [[ ${grille[i]:(($j-1)*2):1} = "$1" ]] && [[ ${grille[i+1]:(($j-1)*2)+2:1} = "$1" ]] && [[ ${grille[i+2]:(($j-1)*2)+4:1} = "$1" ]] && [[ ${grille[i+3]:(($j-1)*2)+6:1} = "$1" ]]; then
                condition=1
            fi
        done
    done
    # Test Diagonale Bas-Gauche vers Haut-Droite
    for ((i=5; i>=3; i--)); do
        for ((j=1; j<=7; j++)); do
            if [[ ${grille[i]:(($j-1)*2):1} = "$1" ]] && [[ ${grille[i-1]:(($j-1)*2)+2:1} = "$1" ]] && [[ ${grille[i-2]:(($j-1)*2)+4:1} = "$1" ]] && [[ ${grille[i-3]:(($j-1)*2)+6:1} = "$1" ]]; then
                condition=1
            fi
        done
    done
    
    if [ $condition -eq 1 ] && [ $1 = "X" ]; then 
        victoire=1
    elif [ $condition -eq 1 ] && [ $1 = "O" ]; then 
        victoire=2
    fi
}

function Victoire_nulle {
    # Test Partie nulle
    for((i=0; i<6; i++)); do 
        for((j=1; j<=7; j++)); do 
            if [ ${grille[i]:($j-1)*2:1} = "_" ]; then
                condition=2
            fi
        done
    done
    if [ $condition -eq 0 ]; then victoire=3; fi
}

# Sauvegarde la partie
function Save {
    echo 'coups='"$coups" > save.cn4
    echo 'pseudo1='"$pseudo1" >> save.cn4
    echo 'pseudo2='"$pseudo2" >> save.cn4
    for((i=0;i<6;i++)); do
        echo 'grille['$i']="'"${grille[i]}"'"' >> save.cn4
    done
}

# Charge la partie
function Load {
	while read line  
	do   
		eval $line  
	done < save.cn4	
}