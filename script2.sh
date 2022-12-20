#!/bin/bash
cat archive.txt | cut -d ':' -f 3 | sed 's/}//' > valeurs.txt
nbr_total=`wc -l < archive.txt | cut -d ' ' -f 1 `
while IFS="" read -r p || [ -n "$p" ]
do
 somme=$somme+$p
 echo $somme
done < valeurs.txt
moyenne=$somme/$nbr_total
echo $moyenne
