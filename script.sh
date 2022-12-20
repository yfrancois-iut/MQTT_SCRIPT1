#!/bin/bash
> test.txt
while true; do  
        mosquitto_sub -C 1 -h iot.iut-blagnac.fr -u student -P student -t iut/bate/etage1/+/luminosite >> test.txt
        lignes=`wc -l < test.txt | cut -d ' ' -f 1`
        echo $lignes
        if [ $lignes -gt 4 ]; then
                cat test.txt > archive.txt
                "" > test.txt
        fi
done