#!/bin/bash
#
# Process Fikka print messages and transfer to iPost.
#
# You could symlink this script to Koha/misc/cronjobs/ and
# run daily with $KOHA_CRONJOB_TRIGGER for logging, some time
# after cronjobs/overdue_notices.pl.
#
# 2019 NatLibFi Brunberg J
#

TRANSFER_TO="...@..." # (iPost SFTP username@hostname)
DATE="$(date +\%Y-\%m-\%d)"
CRONJOBS="$KOHA_PATH/misc/cronjobs"
PRINTDIR="$KOHA_PATH/../koha-dev/var/spool/printmail"

set -o xtrace
cd "$PRINTDIR"

# ODUEDGST is Fikka’s 1st overdue notice, triggered with a 14-day delay;
# ONOTDGST is Fikka’s 2st overdue notice, triggered with a 28-day delay;
# HEco (as in Fi-H, letter class Economy) is defined in koha-conf.xml
"$CRONJOBS/iPostEPL/gather_print_notices.pl" \
    "$PRINTDIR" -m ODUEDGST -m ONOTDGST --prefix HEco

# Koha-Suomi’s old opuscapita_convert_and_send_print_notices.pl is a
# legacy solution waiting to be replaced, and it does not handle all
# special characters, so as a quick-and-dirty workaround let’s just...
iconv -ct latin1//TRANSLIT < "HEco-notices-${DATE}.html" \
    | iconv -f latin1 > "HEco-notices-${DATE}_tr.html"

# Convert messages, but do not actually transfer them to iPost for
# sending yet. SFTP must be left unconfigured in koha-conf.xml.
"$CRONJOBS/iPostEPL/opuscapita_convert_and_send_print_notices.pl" \
    HEco "$PRINTDIR/HEco-notices-${DATE}_tr.html"

[ ! -e "old_notices/HEco-notices-${DATE}.html" ] &&
mv -n "HEco-notices-${DATE}.html" old_notices/ &&
rm "old_notices/HEco-notices-${DATE}_tr.html"

# Transfer to iPost, through a .temppi file as instructed, but only
# if there are some letters to send.
grep --quiet EPLK "epl/HEco-notices-${DATE}_tr.epl" &&
cat << EOF | sftp -b - "$TRANSFER_TO"
ls -l
put "epl/HEco-notices-${DATE}_tr.epl" "HEco-notices-${DATE}.temppi"
ls -l
rename "HEco-notices-${DATE}.temppi" "HEco-notices-${DATE}.epl"
ls -l
bye
EOF
