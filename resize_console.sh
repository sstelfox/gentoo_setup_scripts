#!/bin/bash

function resize_terminal() {
  local IFS='[;' escape geometry x y

  echo -en '\e7\e[r\e[999;999H\e[6n\e8'
  read -sd R escape geometry

  x=${geometry##*;}
  y=${geometry%%;*}

  stty cols ${x} rows ${y}
}

resize_terminal
