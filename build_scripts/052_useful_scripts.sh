#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

# We want to additionally spit out the kernel messages to the KVM serial
# console
if [ "${KERNEL_TARGET}" = "kvm_guest" ]; then
  cat << 'EOF' > /mnt/gentoo/usr/local/bin/resize_console
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
EOF

  chmod +x /mnt/gentoo/usr/local/bin/resize_console
fi
