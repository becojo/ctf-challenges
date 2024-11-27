#!/usr/bin/env sh

echo "Rego Prototype Review"
echo "Which challenge? (1-3):"
read i

echo "Here is the source code:"
echo '```'
cat "./bundles/challenge${i}/challenge${i}.rego" 2>/dev/null || exit 1
echo '```'
echo

echo "What's the flag?"
read flag

function test_flag() {
    echo '{"flag": "'${flag}'"}' | opa eval --stdin-input -f pretty -b "./bundles/challenge${i}" "data.challenge${i}.correct_flag"
}

if [ "$(test_flag)" == "true" ]; then
    echo "Success!"
else
    echo "Incorrect flag"
    exit 1
fi
