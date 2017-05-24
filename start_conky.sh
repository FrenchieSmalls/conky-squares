#!/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/budi

conky -c ~/.conky/squares.conky &
conky -c ~/.conky/filesystem.conky &
