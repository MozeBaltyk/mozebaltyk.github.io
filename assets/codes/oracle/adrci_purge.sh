#!/bin/bash
# Purge every ADR home (uses adrci)
for f in $( adrci exec="show homes" | grep -v "ADR Homes:" ); do
  echo "Purging ${f}"
  adrci exec="set home $f; purge -age 0;"
done
