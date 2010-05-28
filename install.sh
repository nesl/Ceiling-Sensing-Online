#!/bin/bash

# For some reason screen clobbers PATH so we need it set it manually
PATH=/opt/local/bin:/opt/local/sbin:/stow/bin:/stow/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/texbin:/usr/X11/bin:/usr/local/git/bin

case $1 in
1)
  SENSORBOARD=mts300 make micaz install,1 eprb,172.17.4.170
  ;;
2)
  SENSORBOARD=mts300 make micaz install,2 eprb,172.17.4.171
  ;;
6)
  SENSORBOARD=mts300 make micaz install,6 eprb,172.17.4.175
  ;;
7)
  SENSORBOARD=mts300 make micaz install,7 eprb,172.17.4.176
  ;;
8)
  SENSORBOARD=mts300 make micaz install,8 eprb,172.17.4.177
  ;;
11)
  SENSORBOARD=mts300 make micaz install,11 eprb,172.17.4.180
  ;;
12)
  SENSORBOARD=mts300 make micaz install,12 eprb,172.17.4.181
  ;;
16)
  SENSORBOARD=mts300 make micaz install,16 eprb,172.17.4.185
  ;;
17)
  SENSORBOARD=mts300 make micaz install,17 eprb,172.17.4.186
  ;;
*)
  echo "ID should be 1 2 6 7 8 11 12 16 or 17"
  ;;
esac
