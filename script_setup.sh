#!/bin/bash

set -o errexit

mkdir -p /mnt/nfs_source
mount 192.168.122.1:/ /mnt/nfs_source
