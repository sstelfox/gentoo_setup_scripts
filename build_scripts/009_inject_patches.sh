#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

rsync --delete -r patches /mnt/gentoo/etc/portage/
