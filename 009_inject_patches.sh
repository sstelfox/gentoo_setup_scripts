#!/bin/bash

. ./_config.sh
. ./_error_handling.sh

rsync -r patches /mnt/gentoo/etc/portage/
