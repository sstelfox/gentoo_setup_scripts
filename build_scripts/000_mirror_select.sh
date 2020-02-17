#/bin/bash

. ./_config.sh
. ./_error_handling.sh

if [ "${LOCAL}" != "yes" ]; then
  if [ -z "${GENTOO_MIRRORS:-}" ]; then
    # Only attempt to find the fastest Gentoo mirror if the utility is available
    if which mirrorselect &> /dev/null; then
      mirrorselect -o -s 1 -q -D -H -R 'North America' 2> /dev/null >> ./_config.sh
    fi
  fi
fi
