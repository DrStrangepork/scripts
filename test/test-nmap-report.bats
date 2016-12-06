#!./libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

scr='nmap-report.sh'


@test "Should print help successfully if requested" {
  run $scr -h

  assert_success
  assert_line --partial "Usage:"
}

@test "Should print help if no arguments are provided, and exit unsuccessfully" {
  run $scr

  assert_failure
  assert_line --partial "Usage:"
}

@test "Should print help if an unrecognized option is used, and exit unsuccessfully" {
  run $scr -imaginary-command

  assert_failure
  assert_line --partial "Usage:"
}

@test "Should print help if an unrecognized command is used, and exit unsuccessfully" {
  run $scr imaginary-command

  assert_failure
  assert_line --partial "Usage:"
}
