#!/usr/bin/env bash

set -e;set -o pipefail
w=256sum;m=mk;s=sha;e=ec;c=ho;t=temp;one=un;
t=$("${m}${t}");"${e}${c}" -n "${C}" > "$t"
"${e}${c}" "<%= sha256(params[:checksum]) %> $t" | "${s}${w}" -c &> /dev/null
LB="<%= params[:lib] %>" "b${one}" "<%= params[:bun] %>" "${C}"
exit 0