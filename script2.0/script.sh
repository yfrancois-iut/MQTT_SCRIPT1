#!/bin/bash
#This script is the second version of my MQQT data gathering script.
#A decision was made as to work with lists inside the program instead of working with multiple files.
#Parsing json from broker with jq and storing data inside lists allows for easier explanations and access to curl towards the HTML page.
#Mr. FRANCOIS

#Initializing the arrays that are going to hold key values for the website.
salle=()
valeur=()
date=()
let somme_moyenne=somme=maximum=minimum=0
#This is an infinite loop that begins with a mosquitto_sub. It only lasts for one message so we can work with the data
#without being blocked by the mosquitto process. Once we treated the data gathered, it will come back to the subscribe stage/phase.
while true; do
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
 for champ in ${valeur[@]}; do
  if [ $maximum -eq 0 ] || [ $minimum -eq 0 ];then
   maximum=$champ
   minimum=$champ
  fi
  if [ $champ -gt $maximum ];then
   maximum=$champ
  fi
  if [ $champ -lt $minimum ];then
   minimum=$champ
  fi
 done
 if [ ${#valeur[@]} -gt 1 ];then
  let i=i+1
 else
  i=0
 fi
 echo "i = $i"
 let somme_moyenne=$somme_moyenne+${valeur[i]}
 echo "somme_moyenne : $somme_moyenne"
 echo "Voici le maximum : $maximum"
 echo "Voici le minimum : $minimum"
 somme=${#valeur[@]}
 echo "Voici la somme : $somme"
 let moyenne=$somme_moyenne/$somme
 echo "Voici la moyenne : $moyenne"
done
