#!/bin/bash

echo "User Name: jeongyewon" # 사용자 이름 출력
echo "Student Number: 12223815" # 학번 출력
/*whoami 기능을 사용하고 싶으면
user_name=$(whoami)
echo "User Name: $user_name"

read -p "Student Number: " student_number
으로 사용하기*/

echo "[ MENU ]" # 메뉴 출력 시작
echo "1. Get the data of the movie identified by a specific 'movie id' from 'u.item'" # 1번 메뉴 설명
echo "2. Get the data of action genre movies from 'u.item’" # 2번 메뉴 설명
echo "3. Get the average 'rating’ of the movie identified by specific 'movie id' from 'u.data’" # 3번 메뉴 설명
echo "4. Delete the ‘IMDb URL’ from ‘u.item" # 4번 메뉴 설명
echo "5. Get the data about users from 'u.user’" # 5번 메뉴 설명
echo "6. Modify the format of 'release date' in 'u.item’" # 6번 메뉴 설명
echo "7. Get the data of movies rated by a specific 'user id' from 'u.data'" # 7번 메뉴 설명
echo "8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'" # 8번 메뉴 설명
echo "9. Exit" # 9번 메뉴 설명
echo "--------------------------" # 메뉴 출력 끝

while true; do # 무한 루프 시작
    read -p "Enter your choice [ 1-9 ] " choice # 사용자로 부터 메뉴 선택 입력 받음

    case $choice in # 입력받은 메뉴 선택에 따라 다른 작업 수행
      1) # 1번 메뉴 선택 시
        read -p "Please enter 'movie id'(1~1682):" movie_id # 사용자로부터 movie id 입력 받음
        awk -F"|" -v id="$movie_id" '$1 == id {print $0}' u.item # movie id에 해당하는 영화 정보 출력
        ;;
      2) # 2번 메뉴 선택 시
        read -p "Do you want to get the data of ‘action’ genre movies from 'u.item’?(y/n):" answer # 사용자로부터 'y' 또는 'n' 입력 받음
        if [ "$answer" == "y" ]; then # 'y'를 입력받았을 경우
          awk -F"|" '$7 == 1 {print $1, $2}' u.item | sort -n | head -10 # 액션 장르 영화의 id와 제목 출력
        fi
        ;;
      3) # 3번 메뉴 선택 시
        read -p "Please enter the 'movie id’(1~1682):" movie_id # 사용자로부터 movie id 입력 받음
        avg_rating=$(awk -F"\t" -v id="$movie_id" '$2 == id {total += $3; count++} END {printf "%.5f", total/count}' u.data) # movie id에 해당하는 영화의 평균 평점 계산
        echo "average rating of $movie_id: $avg_rating" # 계산된 평균 평점 출력
        ;;
      4) # 4번 메뉴 선택 시
        read -p "Do you want to delete the ‘IMDb URL’ from ‘u.item’?(y/n):" answer # 사용자로부터 'y' 또는 'n' 입력 받음
        if [ "$answer" == "y" ]; then # 'y'를 입력받았을 경우
          awk -F"|" -v OFS="|" '{ $5=""; print $0 }' u.item | head -10 # IMDb URL 삭제 후 정보 출력
        fi
        ;;
      5) # 5번 메뉴 선택 시
        read -p "Do you want to get the data about users from ‘u.user’?(y/n):" answer # 사용자로부터 'y' 또는 'n' 입력 받음
        if [ "$answer" == "y" ]; then # 'y'를 입력받았을 경우
          awk -F"|" '{ printf "user %d is %d years old %s %s
", $1, $2, ($3=="M"?"male":"female"), $4 }' u.user | head -10 # 사용자 정보 출력
        fi
        ;;
      6) # 6번 메뉴 선택 시
        read -p "Do you want to Modify the format of ‘release data’ in ‘u.item’?(y/n):" answer # 사용자로부터 'y' 또는 'n' 입력 받음
        if [ "$answer" == "y" ]; then # 'y'를 입력받았을 경우
          awk -F"|" -v OFS="|" '{
            split($3, date, "-");
            month = (index("JanFebMarAprMayJunJulAugSepOctNovDec", date[2])+2)/3;
            if (month < 10) month = "0" month;
            $3 = date[3] month date[1];
            print $0;
          }' u.item | tail -10 # 영화 출시일 형식 변경 후 출력
        fi
        ;;
      7) # 7번 메뉴 선택 시
        read -p "Please enter the ‘user id’(1~943):" user_id # 사용자로부터 user id 입력 받음
        awk -F"\t" -v id="$user_id" '$1 == id {print $2}' u.data | sort -n | awk '{printf $0 "|"}' # user id가 평가한 영화의 id 출력
        echo ""
        awk -F"\t" -v id="$user_id" '$1 == id {print $2}' u.data | sort -n | head -10 | while read movie_id; do
          title=$(awk -F"|" -v id="$movie_id" '$1 == id {print $2}' u.item) # movie id에 해당하는 영화 제목 가져옴
          echo "$movie_id|$title" # movie id와 제목 출력
        done
        ;;
      8) # 8번 메뉴 선택 시
        read -p "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'?(y/n)" answer # 사용자로부터 'y' 또는 'n' 입력 받음
        if [ "$answer" == "y" ]; then # 'y'를 입력받았을 경우
          awk -F"|" 'BEGIN {OFS="|"} $4 == "programmer" && $2 >= 20 && $2 <= 29 {print $1}' u.user > programmer_ids.txt # programmer이면서 나이가 20~29인 사용자의 id를 파일에 저장
	awk -F"\t" 'BEGIN {while (getline < "programmer_ids.txt") arr[$0] = 1} $1 in arr { sum[$2] += $3; count[$2]++ } END { for (i in sum) { avg = sum[i]/count[i]; printf("%d %f
", i, avg) } }' u.data | sort -n | awk '{printf("%d %.6g
", $1, $2)}' # 저장된 id의 사용자들이 평가한 영화의 평균 평점 계산 후 출력
        rm programmer_ids.txt # 임시 파일 삭제
        fi
        ;;
      9) # 9번 메뉴 선택 시
        echo "Bye!" # 종료 메시지 출력
        exit # 프로그램 종료(반복문 탈출)
        ;;
    esac
done
