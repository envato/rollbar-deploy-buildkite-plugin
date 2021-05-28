#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'
load 'test_helper'

@test "Reports a deploy with minimal configuration" {
  stub_api_call POST 13579

  call_hook_and_verify_stubs

  assert_output --regexp "new.*13579"
  assert_equal "$status" 0
}

@test "Reports a deploy with the specified status" {
  export BUILDKITE_PLUGIN_ROLLBAR_DEPLOY_STATUS="started"
  export EXPECTED_STATUS="started"

  stub_api_call POST 14916

  call_hook_and_verify_stubs

  assert_output --regexp "new.*14916"
  assert_equal "$status" 0
}

@test "Reports a deploy with the specified local username" {
  export BUILDKITE_PLUGIN_ROLLBAR_DEPLOY_LOCAL_USERNAME="a-local-user"
  export EXPECTED_LOCAL_USERNAME="a-local-user"

  stub_api_call POST 74123

  call_hook_and_verify_stubs

  assert_output --regexp "new.*74123"
  assert_equal "$status" 0
}

@test "Reports a deploy with the specified Rollbar username" {
  export ROLLBAR_USERNAME="a-rollbar-user"
  export EXPECTED_ROLLBAR_USERNAME="a-rollbar-user"

  stub_api_call POST 78963

  call_hook_and_verify_stubs

  assert_output --regexp "new.*78963"
  assert_equal "$status" 0
}

@test "Updates a deploy with minimal configuration" {
  export DEPLOY_ID=24680

  stub_api_call PATCH "$DEPLOY_ID"

  call_hook_and_verify_stubs

  assert_output --regexp "existing.*24680"
  assert_equal "$status" 0
}

@test "Uses deploy_id from metadata" {
  export BUILDKITE_PLUGIN_ROLLBAR_DEPLOY_BUILDKITE_METADATA_DEPLOY_ID="rollbar_deploy_id"

  stub_metadata_deploy_id 35741
  stub_api_call PATCH 35741

  call_hook_and_verify_stubs

  assert_output --regexp "existing.*35741"
  assert_equal "$status" 0
}

@test "Stores deploy_id into metadata" {
  export BUILDKITE_PLUGIN_ROLLBAR_DEPLOY_BUILDKITE_METADATA_DEPLOY_ID="rollbar_deploy_id"

  stub_metadata_deploy_id 35741
  stub_api_call PATCH 35741

  call_hook_and_verify_stubs

  assert_output --regexp "existing.*35741"
  assert_equal "$status" 0
}

@test "Sets the new deploy_id when metadata is unset" {
  export BUILDKITE_PLUGIN_ROLLBAR_DEPLOY_BUILDKITE_METADATA_DEPLOY_ID="rollbar_deploy_id"

  stub_no_metadata_deploy_id 95123
  stub_api_call POST 95123

  call_hook_and_verify_stubs

  assert_output --regexp "new.*95123"
  assert_equal "$status" 0
}
