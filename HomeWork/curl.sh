#!/bin/bash
ip=("173.194.222.113" "87.250.250.242" "192.168.0.1")
while ((1==1))
do
  for i in ${ip[@]}
    do
      for j in {1..5}
      do
        echo -n $i" ";http_code=$(curl -s -o /dev/null -w '%{http_code}' --connect-timeout 3 $i:80);echo $http_code
      done
    done
    if [ $http_code = "000" ]
      then
        echo $i>curl_err.log
        break;
    fi
done >curl.log


#do for j in {1..5}; do echo -n $i" ";echo $(curl -s -o /dev/null -w '%{http_code}' --connect-timeout 3 $i:80); done; done > curl.log