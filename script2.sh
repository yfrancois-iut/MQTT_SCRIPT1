#!/bin/bash
max=0
min=0
cat archive.txt | cut -d ':' -f 3 | sed 's/}//' > valeurs.txt
nbr_total=`wc -l < archive.txt | cut -d ' ' -f 1 `
while IFS="" read -r p || [ -n "$p" ]
do
 let somme=$somme+$p
 echo $p
 if [ $max == 0 ];then
  max=$p
 fi
 if [ $min == 0 ];then
  min=$p
 fi
 if [ $p -gt $max ];then
  max=$p
 fi
 if [ $p -lt $min ];then
  min=$p
 fi
done<valeurs.txt
echo "La somme de toutes les valeurs est : $somme"
let moyenne=$somme/$nbr_total
echo "La moyenne de toutes les valeurs est : $moyenne"
echo "Le minimum de toutes les valeurs est : $min"
echo "Le maximums de toutes les valeurs est : $max"