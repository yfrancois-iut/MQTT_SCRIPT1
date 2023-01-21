#!/bin/bash
#Fonction ajoutant les valeurs au sein du premier tableau
fonction_tableau1_site() {
 fichier='/home/etud/script2.0/capteurs.html'
 balise='<!--Tab1-->'
 ligne='<td class ="gauche">$1</td> <td class="droite">$2</td> <td class="droite">$3</td>'
 sed -i 's/$balise/\n\t\t\t\t\t$ligne/' $fichier
}

fonction_tableau1_site "70" "E105" "13/02/01"
