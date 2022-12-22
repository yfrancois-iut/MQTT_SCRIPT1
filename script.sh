#!/bin/bash
> temp.txt
> date.txt
while true; do  
 mosquitto_sub -C 1 -h iot.iut-blagnac.fr -u student -P student -t iut/bate/etage1/+/luminosite >> temp.txt
 lignes=`wc -l < temp.txt | cut -d ' ' -f 1`
 date +%x-%X >> date.txt
 if [ $lignes -gt 20 ]; then
  cp temp.txt archive.txt
  cp date.txt datarchive.txt
  > temp.txt
  > date.txt
 fi
done