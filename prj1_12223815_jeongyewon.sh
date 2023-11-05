#!/bin/bash

echo "User Name: jeongyewon"
echo "Student Number: 12223815"
echo "[ MENU ]"
echo "1. Get the data of the movie identified by a specific 'movie id' from 'u.item'"
echo "2. Get the data of action genre movies from 'u.item’"
echo "3. Get the average 'rating’ of the movie identified by specific 'movie id' from 'u.data’"
echo "4. Delete the ‘IMDb URL’ from ‘u.item"
echo "5. Get the data about users from 'u.user’"
echo "6. Modify the format of 'release date' in 'u.item’"
echo "7. Get the data of movies rated by a specific 'user id' from 'u.data'"
echo "8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'"
echo "9. Exit"
echo "--------------------------"

while true; do
    read -p "Enter your choice [ 1-9 ] " choice

    case $choice in
      1)
        read -p "Please enter 'movie id'(1~1682):" movie_id
        awk -F"|" -v id="$movie_id" '$1 == id {print $0}' u.item
        ;;
      2)
        read -p "Do you want to get the data of ‘action’ genre movies from 'u.item’?(y/n):" answer
        if [ "$answer" == "y" ]; then
          awk -F"|" '$7 == 1 {print $1, $2}' u.item | sort -n | head -10
        fi
        ;;
      3)
        read -p "Please enter the 'movie id’(1~1682):" movie_id
        avg_rating=$(awk -F"\t" -v id="$movie_id" '$2 == id {total += $3; count++} END {printf "%.5f", total/count}' u.data)
        echo "average rating of $movie_id: $avg_rating"
        ;;
      4)
        read -p "Do you want to delete the ‘IMDb URL’ from ‘u.item’?(y/n):" answer
        if [ "$answer" == "y" ]; then
          awk -F"|" -v OFS="|" '{ $5=""; print $0 }' u.item | head -10
        fi
        ;;
      5)
        read -p "Do you want to get the data about users from ‘u.user’?(y/n):" answer
        if [ "$answer" == "y" ]; then
          awk -F"|" '{ printf "user %d is %d years old %s %s\n", $1, $2, ($3=="M"?"male":"female"), $4 }' u.user | head -10
        fi
        ;;
      6)
        read -p "Do you want to Modify the format of ‘release data’ in ‘u.item’?(y/n):" answer
        if [ "$answer" == "y" ]; then
          awk -F"|" -v OFS="|" '{
            split($3, date, "-");
            month = (index("JanFebMarAprMayJunJulAugSepOctNovDec", date[2])+2)/3;
            if (month < 10) month = "0" month;
            $3 = date[3] month date[1];
            print $0;
          }' u.item | tail -10
        fi
        ;;
      7)
        read -p "Please enter the ‘user id’(1~943):" user_id
        awk -F"\t" -v id="$user_id" '$1 == id {print $2}' u.data | sort -n | awk '{printf $0 "|"}'
        echo ""
        awk -F"\t" -v id="$user_id" '$1 == id {print $2}' u.data | sort -n | head -10 | while read movie_id; do
          title=$(awk -F"|" -v id="$movie_id" '$1 == id {print $2}' u.item)
          echo "$movie_id|$title"
        done
        ;;
      8)
        read -p "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'?(y/n)" answer
        if [ "$answer" == "y" ]; then
          awk -F"|" 'BEGIN {OFS="|"} $4 == "programmer" && $2 >= 20 && $2 <= 29 {print $1}' u.user > programmer_ids.txt
	awk -F"\t" 'BEGIN {while (getline < "programmer_ids.txt") arr[$0] = 1} $1 in arr { sum[$2] += $3; count[$2]++ } END { for (i in sum) { avg = sum[i]/count[i]; printf("%d %f\n", i, avg) } }' u.data | sort -n | awk '{printf("%d %.6g\n", $1, $2)}'
        rm programmer_ids.txt
        fi
        ;;
      9)
        echo "Bye!"
        exit
        ;;
    esac
done

