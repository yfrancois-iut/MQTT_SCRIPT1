#!/bin/bash
#This script is the second version of my MQQT data gathering script.
#A decision was made as to work with lists inside the program instead of working with multiple files.
#Parsing json from broker with jq and storing data inside lists allows for easier explanations and access to curl towards the HTML page.
#Mr. FRANCOIS

#Initializing the arrays that are going to hold key values for the website.
salle=()
valeur=()
date=()
#This is an infinite loop that begins with a mosquitto_sub. It only lasts for one message so we can work with the data
#without being blocked by the mosquitto process. Once we treated the data gathered, it will come back to the subscribe stage/phase.
while true; do
 valeurs_brutes=`mosquitto_sub -C 1 -h iot.iut-blagnac.fr -u student -P student -t iut/bate/etage1/+/luminosite`
#ajout_salle is variable in which is temporarly stored the room of the last MQTT output, jq treating the whole output to only keep the value of 
#the room field. The array salle() is then incremented with the datat stored in ajout_salle.
 ajout_salle=`echo $valeurs_brutes | jq '.room'`
 salle+=($ajout_salle)
 echo $salle
done
