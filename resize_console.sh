#!/bin/bash

if [ "${BASH_SOURCE}" = "$0" ]; then
  echo "This file is expected to be sourced not executed"
  exit 0
fi

function resize_terminal() {
  local IFS='[;' escape geometry x y

  print -n '\e7\e[r\e[999;999H\e[6n\e8'
  read -sd R escape geometry

  x=${geometry##*;}
  y=${geometry%%;*}

  if [[ ${COLUMNS} -eq ${x} && ${LINES} -eq ${y} ]]; then
    print "Terminal doesn't require resizing, leaving at: ${x}x${y}"
  else
    print "Old terminal size was ${COLUMNS}x${LINES}, Updated to ${x}x${y}"
    stty cols ${x} rows ${y}
  fi
}

resize_terminal
