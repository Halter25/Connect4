# Shebang pour forcer le programme à utiliser l'interpreteur shell "Bash"
#!/bin/bash

# On importe les fonctions 
source connect4_function.sh

victoire=0
while [ $victoire = 0 ]; do

    # Saisie sécurisé : Sortie seulement si un chiffre digital (0, 1 à 9) ET compris dans l'interval
	while [[ ! $choix =~ ^[[:digit:]]{1}$ ]] || [[ $choix -lt 0 || $choix -gt 1 ]]; do
		Menu
	done

    # "Switch" en fonction du choix de menu
	case "$choix" in
		1)  # Lancer une nouvelle partie
            
            # On vérifie s'il y a déjà une partie en cours
            if [ -f save.cn4 ]; then
                while [[ $reboot != "o" ]] && [[ $reboot != "O" ]] && [[ $reboot != "n" ]] && [[ $reboot != "N" ]]; do
                    # Il y a déjà une partie en cours, on demande à l'utilisateur s'il veut la reprendre
                    read -p " Reprendre la partie en cours ? (o/n) : " reboot
                done
            fi

            # n/N = Recommencer ; o/O : Chargement de la save
            if [ $reboot = "n" ] || [ $reboot = "N"] || [ ! -f save.cn4 ]; then
                # Les joueurs choisissent leurs pseudos
                Choix_pseudo
                # On initialise la grille de jeu
                Initialiser_grille
                # On initialise le compteur de tour/coup
                coups=0
                # On initialise la sauvegarde
                Save
            else
                # On charge la sauvegarde
                Load
            fi

			while [[ $victoire = 0 ]]; do
                # Incrementation du compteur de coup/tour
				coups=$(($coups+1))
                # On utilise le compteur de coup/tour pour savoir a qui est-ce de jouer
				if [[ $((coups%2)) = 1 ]]; then
					Jouer $pseudo1 X
                    # Inutile de vérifier avant le 7éme coups car aucun joueur n'aura assez joué pour gagner
                    if [ $coups -ge 7 ]; then Condition_victoire X ; fi
				else
                    # On appelle a fonction en lui envoyant comme parametre le pseudo du joueur et son jeton
					Jouer $pseudo2 O
                    if [ $coups -ge 7 ]; then Condition_victoire O ; fi
				fi
                Save
			done
            case "$victoire" in
                1) echo "$pseudo1 a gagné !";;
                2) echo "$pseudo2 a gagné !";;
                3) echo "Partie Nulle" ;;
            esac
		;;
		0) # Quitter le jeu
            exit 
        ;;
	esac
done
# On supprime la sauvegarde car la partie et fini et on vérifi avant que personne ne l'a supprimé avant
if [ -f save.cn4 ]; then rm save.cn4; fi