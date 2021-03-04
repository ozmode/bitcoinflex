#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

BITCOINFLEXD=${BITCOINFLEXD:-$SRCDIR/bitcoinflexd}
BITCOINFLEXCLI=${BITCOINFLEXCLI:-$SRCDIR/bitcoinflex-cli}
BITCOINFLEXTX=${BITCOINFLEXTX:-$SRCDIR/bitcoinflex-tx}
BITCOINFLEXQT=${BITCOINFLEXQT:-$SRCDIR/qt/bitcoinflex-qt}

[ ! -x $BITCOINFLEXD ] && echo "$BITCOINFLEXD not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
BFXVER=($($BITCOINFLEXCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$BITCOINFLEXD --version | sed -n '1!p' >> footer.h2m

for cmd in $BITCOINFLEXD $BITCOINFLEXCLI $BITCOINFLEXTX $BITCOINFLEXQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${BFXVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${BFXVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
