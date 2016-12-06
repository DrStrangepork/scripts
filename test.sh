# Run this file to run all the tests, once
for test in test/*.bats; do
    scr=${test#test/test-}
    echo ${scr%.bats}
    ./test/libs/bats/bin/bats ${test}
done
echo;echo
