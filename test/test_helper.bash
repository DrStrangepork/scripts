# setupTestEnv() {
#   export TEST_DIRECTORY="$(mktemp -d)"
# }

# teardownTestEnv() {
#   if [ $BATS_TEST_COMPLETED ]; then
#     rm -rf $TEST_DIRECTORY
#   else
#     echo "** Did not delete $TEST_DIRECTORY, as test failed **"
#   fi
# }

# MakeKey_cert_file_test1() {
#     touch $TEST_DIRECTORY/test.csr
# }

# MakeKey_cert_file_test2() {
#     rm $TEST_DIRECTORY/test.csr
#     touch $TEST_DIRECTORY/test.key
# }

# MakeKey_cert_file_test3() {
#     rm $TEST_DIRECTORY/test.key
#     touch $TEST_DIRECTORY/test.passphrase.txt
# }

# MakeKey_cert_file_test4() {
#     rm $TEST_DIRECTORY/test.passphrase.txt
# }
