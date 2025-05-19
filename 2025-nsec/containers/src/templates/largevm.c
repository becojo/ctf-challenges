#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#define TRUE 0xAA
#define FALSE 0xFF
#define OP_ADD 0x54
#define OP_SUB 0x02
#define OP_DONE 0xff

#ifndef XA
#error "XA not defined"
#endif

#ifndef XB
#error "XB not defined"
#endif

typedef int (*func_t)(int index, int op, int value);

int sum = 0;

int process(
  const char *password,
  const char *input,
  func_t callback
) {
  sum = 0;

  int password_len = strlen(password);
  for(int i = 0; i < password_len; i++) {
    sum += password[i];
  }

  int input_len = strlen(input);

  /*<%
    password_sum = params[:checksum].bytes.sum
    calls = params[:solution].bytes.each.with_index.to_a.shuffle.flat_map do |(c, i)|
      parts = partition(c)
      parts = parts.map do |(op, value)|
        [i, op, value]
      end
      parts << [i, 0x02, params[:offset][i]] # OP_SUB
      parts
    end.shuffle
  %>*/

  // <% calls.each do |(i, op, value)| %>
  // <% if op == ?+ %>
  callback(atoi("<%= i %>"), OP_ADD, atoi("<%= value  ^ password_sum %>") ^ XA);
  // <% elsif op == ?- %>
  callback(atoi("<%= i %>"), OP_SUB, atoi("<%= value  ^ password_sum %>") ^ XB);
  // <% end %>
  // <% end %>

  callback(input_len, OP_DONE, sum);

  return TRUE;
}
