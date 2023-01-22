#!/bin/bash
#This script is the second version of my MQQT data gathering script.
#A decision was made as to work with lists inside the program instead of working with multiple files.
#Parsing json from broker with jq and storing data inside lists allows for easier explanations and access to curl towards the HTML page.
#Mr. FRANCOIS

#Fonction ajoutant les valeurs instantanées au sein du premier tableau
fonction_tableau1_site() {
 luminosite=$1
 salle=$2
 date=$3
 fichier='./capteurs.html'
 balise='<!--Tab1-->'
 ligne=$(echo '<td class ="gauche">'$luminosite' lux </td> <td class="droite">'$salle'</td> <td class="droite">'$date'</td>')
 sed -i "s#$balise#<!--Tab1-->\n\t\t\t\t<tr>\n\t\t\t\t\t$ligne\n\t\t\t\t</tr>#" $fichier
}
fonction_tableau2_site() {
 m=$1
 min=$2
 max=$3
 m1=$4
 min1=$5
 max1=$6
 m2=$7
 min2=$8
 max2=$9
 fichier='./capteurs.html'
 balisedebut='<!--Tab2debut-->'
 balisefin='<!--Tab2fin-->'
 ligne1=$(echo '<th>E101</th> <td class ="gauche">'$m1' lux </td> <td class="droite">'$min1' lux </td> <td class="droite">'$max1' lux </td>')
 ligne2=$(echo '<th>E102</th> <td class ="gauche">'$m2' lux </td> <td class="droite">'$min2' lux </td> <td class="droite">'$max2' lux </td>')
 ligne3=$(echo '<th>Global</th> <td class ="gauche">'$m' lux </td> <td class="droite">'$min' lux </td> <td class="droite">'$max' lux </td>')
 perl -0777 -i -pe "s|<!--Tab2debut-->.*<!--Tab2fin-->|<!--Tab2debut-->\n\t\t\t\t<tr>\n\t\t\t\t\t$ligne1\n\t\t\t\t</tr>\n\t\t\t\t<tr>\n\t\t\t\t\t$ligne2\n\t\t\t\t</tr>\n\t\t\t\t<tr>\n\t\t\t\t\t$ligne3\n\t\t\t\t</tr><!--Tab2fin-->|s" $fichier
}
#Initializing the arrays that are going to hold key values for the website.
salle=()
valeur=()
date=()
let j=k=i=somme_moyenne=somme_e102=somme_e101=moyenne_e101=moyenne_e102=somme=maximum=minimum=minimum_e101=minimum_e102=maximum_e101=maximum_e102=0
#This is an infinite loop that begins with a mosquitto_sub. It only lasts for one message so we can work with the data
#without being blocked by the mosquitto process. Once we treated the data gathered, it will come back to the subscribe stage/phase.
while true; do
 if [ "$i" -ge "5" ] || [ "$maximum" -eq "0" ];then
  echo 'YES'
  cat ./capteurs_debut.html > capteurs.html
  curl -u "4183242_yfrancois:Tu76./gh" -T ./capteurs.html ftp://yfrancois.atwebpages.com/SAE15/capteurs.html
  salle=()
  valeur=()
  date=()
  let j=k=i=somme_moyenne=somme_e102=somme_e101=moyenne_e101=moyenne_e102=somme=maximum=minimum=minimum_e101=minimum_e102=maximum_e101=maximum_e102=0
 fi
 valeurs_brutes=`mosquitto_sub -C 1 -h iot.iut-blagnac.fr -u student -P student -t iut/bate/etage1/+/luminosite`
#ajout_salle is variable in which is temporarly stored the room of the last MQTT output, jq treating the whole output to only keep the value of 
#the room field. It is then treated with cut in order to remove the quotes. The array salle() is then incremented with the data stored in ajout_salle.
 ajout_salle=`echo $valeurs_brutes | jq '.room' | cut -d '"' -f 2`
 salle+=($ajout_salle)
#Same principle as for salle.
 ajout_valeur=`echo $valeurs_brutes | jq '.value'`
 valeur+=($ajout_valeur)
#Copy-pasted the formatting method of my previous script. The output of the date command is then stored in date() array.
 ajout_date=`date +%x-%X`
 date+=($ajout_date)
#This down below is a debugging feature that prints the three arrays to make sure that the previous commands do what they are supposed to do.
 echo ${salle[@]}
 echo ${valeur[@]}
 echo ${date[@]}
#Loop that iterates through every element of the valeur[] array.
 for champ in ${valeur[@]}; do
#Initalizing maximum and minimum
  if [ $maximum -eq 0 ] || [ $minimum -eq 0 ];then
   maximum=$champ
   minimum=$champ
  fi
#Updating maximum and minimum by going through every element each time we enter the loop.
  if [ $champ -gt $maximum ];then
   maximum=$champ
  fi
  if [ $champ -lt $minimum ];then
   minimum=$champ
  fi
 done
#Initalizing and index that is used to get the current last value of the valeur[] array. ${#valeur[@]} gives out the total number of values in the array.
 if [ ${#valeur[@]} -gt 1 ];then
  let i=i+1
 else
  i=0
 fi
#All 'echos" are meant for debugging and visualizing the process of the script and the values outputed.
#Calculus of moyenne (=average) and somme_moyenne(=the sum of every value in the array in order to calculate the average.
 let somme_moyenne=$somme_moyenne+${valeur[i]}
 somme=${#valeur[@]}
 moyenne=$(echo "scale=2;$somme_moyenne/$somme" | bc)
 if [[ "${salle[i]}" == "E101" ]]; then
  valeur_e101=${valeur[i]}
  if [ "$j" = "0" ];then
   maximum_e101=$valeur_e101
   minimum_e101=$valeur_e101
  fi
  if [ $valeur_e101 -gt $maximum_e101 ];then
   maximum_e101=$valeur_e101
  fi
  if [ $valeur_e101 -lt $minimum_e101 ];then
   minimum_e101=$valeur_e101
  fi
  let j=j+1
  somme_e101=$(echo "scale=2;$somme_e101+$valeur_e101" | bc)
  moyenne_e101=$(echo "scale=2;$somme_e101/$j" | bc)
 fi
 if [[ "${salle[i]}" == "E102" ]]; then
  valeur_e102=${valeur[i]}
  if [ "$k" = "0" ];then
   maximum_e102=$valeur_e102
   minimum_e102=$valeur_e102
  fi
  if [ $valeur_e102 -gt $maximum_e102 ];then
   maximum_e102=$valeur_e102
  fi
  if [ $valeur_e102 -lt $minimum_e102 ];then
   minimum_e102=$valeur_e102
  fi
  let k=k+1
  somme_e102=$(echo "scale=2;$somme_e102+$valeur_e102" | bc)
  moyenne_e102=$(echo "scale=2;$somme_e102/$k" | bc)
 fi
 echo 'E102' $moyenne_e102 $minimum_e102 $maximum_e102
 echo 'E101' $moyenne_e101 $minimum_e101 $maximum_e101
 echo 'global' $moyenne $minimum $maximum
#Calling a function that takes in 3 parameters/arguments in order to integrate them to an HTML table
 fonction_tableau1_site ${valeur[i]} ${salle[i]} ${date[i]}
 fonction_tableau2_site $moyenne $minimum $maximum $moyenne_e101 $minimum_e101 $maximum_e101 $moyenne_e102 $minimum_e102 $maximum_e102
#The curl function is used to upload the modified HTML file *capteurs.html* via FTP towards the website
 curl -u "4183242_yfrancois:Tu76./gh" -T ./capteurs.html ftp://yfrancois.atwebpages.com/SAE15/capteurs.html
done
