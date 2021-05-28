#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'
load 'test_helper'

# FIXME: validation tests are brittle

@test "Fails appropriately if credentials are missing" {
  unset ROLLBAR_ACCESS_TOKEN

  run "$PWD/hooks/command"

  assert_equal "$status" 1
  assert_output --regexp '[Mm]issing.*ROLLBAR_ACCESS_TOKEN'
}

@test "Fails appropriately if version is missing" {
  unset BUILDKITE_PLUGIN_ROLLBAR_DEPLOY_VERSION

  run "$PWD/hooks/command"

  echo "$output"

  assert_equal "$status" 1
  assert_output 'A value is required for "version".'
}

@test "Fails appropriately if environment is missing" {
  unset BUILDKITE_PLUGIN_ROLLBAR_DEPLOY_ENVIRONMENT

  run "$PWD/hooks/command"

  assert_equal "$status" 1
  assert_output 'A value is required for "environment".'
}
