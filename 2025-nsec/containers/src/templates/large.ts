import { dlopen, FFIType, suffix, JSCallback, CString } from "bun:ffi";
import { CryptoHasher, $ } from "bun";

const TRUE = 0xaa,
  FALSE = 0xff;

function sha256(str: string) {
  const hasher = new CryptoHasher("sha256");
  hasher.update(str);
  return hasher.digest("hex");
}

async function getInput() {
  for await (const line of console) {
    return line;
  }
  return "";
}

async function getLib() {
  const { LB } = process.env;
  var parts = [];
  parts.push(LB);
  parts.push(suffix);
  return parts.join(".");
}

// <% password_sum = params[:checksum].bytes.sum %>

const runPassword = process.argv[2];
if (sha256(runPassword) != "<%= sha256(params[:checksum]) %>") {
  process.exit(1);
}

/*
var passwordSum = 0;
for(var i = 0; i < runPassword.length; i++) {
  passwordSum += runPassword.charCodeAt(i);
}
*/

var input = await getInput();
var state: number[] = JSON.parse("<%= params[:offset].to_json %>")

for (var i = 0; i < state.length; i++) {
  state[i] = -input.charCodeAt(i) || 0;
}

const lib = dlopen(await getLib(), {
  process: {
    args: [FFIType.cstring, FFIType.cstring, FFIType.pointer],
    returns: FFIType.int,
  },
});

const OP_ADD = 0x54,
  OP_SUB = 0x02,
  OP_DONE = 0xff;



type args = { i: number; op: any; value: number };
const handlers: Record<number, (args: args) => void> = {
  [OP_ADD]: ({i, value}: args) => {
    state[i] += value ^ +"<%= password_sum ^ params[:xor_a] %>";
  },
  [OP_SUB]: ({i, value}: args) => {
    state[i] -= value ^ +"<%= password_sum ^ params[:xor_b] %>";
  },
  [OP_DONE]: (_: args) => {
    if (state.every(is(0))) {
      process.exit(0);
    } else {
      process.exit(1);
    }
  },
}

function is(a: any) {
  return (x: any) => x == a;
}

const callback = new JSCallback(
  (i, op, value) => {
    handlers[+op]({i, value, op});
    return TRUE;
  },
  {
    returns: "int",
    args: [FFIType.int, FFIType.int, FFIType.int],
  }
);

var result = lib.symbols.process(
  Buffer.from(process.argv[2]),
  Buffer.from(input),
  callback.ptr
);

if (result != TRUE) {
  process.exit(1);
}
