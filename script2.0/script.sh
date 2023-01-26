#!/bin/bash
#This script is the second version of my MQQT data gathering script.
#A decision was made as to work with lists inside the program instead of working with multiple files.
#Parsing json from broker with jq and storing data inside lists allows for easier explanations and access to curl towards the HTML page.
#Mr. FRANCOIS

#Declaring a function that edits the content of the first table
fonction_tableau1_site() {
#Attributing the value of the arguments passed in the function as local variables
 luminosite=$1
 salle=$2
 date=$3
#Naming the file destination for sed
 fichier='./capteurs.html'
#Naming the flag that will help sed orientate itself in the HMTL file and allow for dynamic table editing.
 balise='<!--Tab1-->'
#ligne is the variable that stores the table row with the actualized variables passed as arguments and stored in the previously mentionned local variables.
 ligne=$(echo '<td class ="gauche">'$luminosite' lux </td> <td class="droite">'$salle'</td> <td class="droite">'$date'</td>')
#sed is a stream editor. With the option -i, we edit the HTML file without printing to STDOUT.
#s is for substitue. # are alternative delimeters that we are force to use since HTML uses a lot of / which are the default delimiters for sed.
#Our command here substitues balise with what follows, which is the balise itself, followed by formatting characters :
#\n for newline ; \t for tabulation : we essentially print ligne in between HTML tags (here <td> and </td>)  with proper indentation.
#Lastly, the variable containing the to to be modified file address is placed at the end of the command. 
 sed -i "s#$balise#<!--Tab1-->\n\t\t\t\t<tr>\n\t\t\t\t\t$ligne\n\t\t\t\t</tr>#" $fichier
}
#Declaring a second function that edits the content of the second table
fonction_tableau2_site() {
#Attributing the value of the arguments passed in the function as local variables
 m=$1
 min=$2
 max=$3
 m1=$4
 min1=$5
 max1=$6
 m2=$7
 min2=$8
 max2=$9

#Naming the file destination for sed
 fichier='./capteurs.html'
#Naming the first flag that will help perl orientate itself in the HMTL file and allow for dynamic table editing.
 balisedebut='<!--Tab2debut-->'
#Naming the second flag that will help perl orientate itself in the HMTL file and allow for dynamic table editing.
 balisefin='<!--Tab2fin-->'
#ligne1-3 are the variables that store the table rows with the actualized variables passed as arguments and stored in the previously mentionned local variables.
 ligne1=$(echo '<th>E101</th> <td class ="gauche">'$m1' lux </td> <td class="droite">'$min1' lux </td> <td class="droite">'$max1' lux </td> <td class="droite">'${10}' lux </td> <td class="droite">'${11}' lux </td>')
 ligne2=$(echo '<th>E102</th> <td class ="gauche">'$m2' lux </td> <td class="droite">'$min2' lux </td> <td class="droite">'$max2' lux </td> <td class="droite">'${12}' lux </td> <td class="droite">'${13}' lux </td>')
 ligne3=$(echo '<th>Global</th> <td class ="gauche">'$m' lux </td> <td class="droite">'$min' lux </td> <td class="droite">'$max' lux </td> <td class="droite">'${14}' lux </td> <td class="droite">'${15}' lux </td>')
#perl is an interpretor and programming language that we use here as a stream editor like sed, except it is less tideous to replace a range of characters contained by two strings.
#-0 allows for slurping the file (the 777 following is a big octal number that allows for storing most files passed as an argument.)
#-i ,like in sed, redirects the output to the file. -pe is a combination of two parameters.
#-e makes the following content as to behave like a script on its own, allowing us to not call a perl script but to write it directly in our bash script.
#-p executes the script.
#s is for substitution like in sed. We also use an alternative separator for the same reasons as with sed. Here | instead of /.
#.* allows for matching any characters between the two HTML tags/comments, characters which are going to be replaced by the following expression.
 perl -0777 -i -pe "s|<!--Tab2debut-->.*<!--Tab2fin-->|<!--Tab2debut-->\n\t\t\t\t<tr>\n\t\t\t\t\t$ligne1\n\t\t\t\t</tr>\n\t\t\t\t<tr>\n\t\t\t\t\t$ligne2\n\t\t\t\t</tr>\n\t\t\t\t<tr>\n\t\t\t\t\t$ligne3\n\t\t\t\t</tr><!--Tab2fin-->|s" $fichier
}
#Initializing the arrays and variables that are going to hold key values for the website.
salle=()
valeur=()
date=()
let jo=ko=io=j=k=i=somme_moyenne=somme_e102=somme_e101=moyenne_e101=moyenne_e102=somme=maximum=minimum=minimum_e101=minimum_e102=maximum_e101=maximum_e102=0
#This is an infinite loop that begins with a mosquitto_sub. It only lasts for one message so we can work with the data
#without being blocked by the mosquitto process. Once we treated the data gathered, it will come back to the subscribe stage/phase.
#The first if loop is about resetting the webpage at every startup of the script, and everytime the index i reaches a certain desired value.
while true; do
 if [ "$i" -ge "10" ] || [ "$maximum" -eq "0" ];then
  cat ./capteurs_debut.html > capteurs.html
  curl -s -u "4183242_yfrancois:Tu76./gh" -T ./capteurs.html ftp://yfrancois.atwebpages.com/SAE15/capteurs.html
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
# echo ${salle[@]}
# echo ${valeur[@]}
# echo ${date[@]}
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
#Updating the historical extremums. io being an index that doesn't reset itself everytime the program loops around.
 if [ $io -eq 0 ];then
  min_historique=$maximum
  max_historique=$minimum
 fi
 if [ $ajout_valeur -gt $max_historique ];then
  max_historique=$ajout_valeur
 fi
 if [ $ajout_valeur -lt $min_historique ];then
  min_historique=$ajout_valeur
 fi
#Initalizing and index that is used to get the current last value of the valeur[] array. ${#valeur[@]} gives out the total number of values in the array.
 if [ ${#valeur[@]} -gt 1 ];then
  let i=i+1
 else
  i=0
 fi
 let io=io+1
#All 'echos" are meant for debugging and visualizing the process of the script and the values outputed.
#Calculus of moyenne (=average) and somme_moyenne(=the sum of every value in the array) in order to calculate the average.
 let somme_moyenne=$somme_moyenne+${valeur[i]}
 somme=${#valeur[@]}
#Passing the mathematical division to the bc interpreter with scale=2 in order to have a more precise average : rounded to 2 decimal places.
 moyenne=$(echo "scale=2;$somme_moyenne/$somme" | bc)
#If conditions in order to have separate stats for each room. The math is the same as for the global values, except for the index that is used.
#The said indexes (specific for each room, j or k) are only incremented when entering the room loop they are linked to.
 if [[ "${salle[i]}" == "E101" ]]; then
  valeur_e101=${valeur[i]}
#Initializing the maximum and minimum to be the first value of the room.
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
#Same as previously, indexes with an o at the end are not resseted by the end of the while loop. Calculating extremums for room 101.
  if [ $jo -eq 0 ];then
   min_historique101=$maximum
   max_historique101=$minimum
  fi
  if [ $valeur_e101 -gt $max_historique101 ];then
   max_historique101=$valeur_e101
  fi
  if [ $valeur_e101 -lt $min_historique101 ];then
   min_historique101=$valeur_e101
  fi
  let jo=jo+1
  let j=j+1
  let somme_e101=$somme_e101+$valeur_e101
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
  if [ $ko -eq 0 ];then
   min_historique102=$maximum_e102
   max_historique102=$minimum_e102
  fi
  if [ $valeur_e102 -gt $max_historique102 ];then
   max_historique102=$valeur_e102
  fi
  if [ $valeur_e102 -lt $min_historique102 ];then
   min_historique102=$valeur_e102
  fi
  let ko=ko+1
  let k=k+1
  let somme_e102=$somme_e102+$valeur_e102
  moyenne_e102=$(echo "scale=2;$somme_e102/$k" | bc)
 fi
#Debugging echos
# echo E102' $moyenne_e102 $minimum_e102 $maximum_e102
# echo E101' $moyenne_e101 $minimum_e101 $maximum_e101
# echo global' $moyenne $minimum $maximum
#Calling a function that takes in 3 parameters/arguments in order to integrate them to an HTML table
 fonction_tableau1_site ${valeur[i]} ${salle[i]} ${date[i]}
#This function takes in 15 arguments that are arranged in a table in order to show statistics about the data gathered (More info in the function itself.)
 fonction_tableau2_site $moyenne $minimum $maximum $moyenne_e101 $minimum_e101 $maximum_e101 $moyenne_e102 $minimum_e102 $maximum_e102 $min_historique101 $max_historique101 $min_historique102 $max_historique102 $min_historique $max_historique
#The curl function is used to upload the modified HTML file *capteurs.html* via FTP towards the website
 curl -s -u "4183242_yfrancois:Tu76./gh" -T ./capteurs.html ftp://yfrancois.atwebpages.com/SAE15/capteurs.html
done
