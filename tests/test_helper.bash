#!/usr/bin/env bats

declare -a _AUTO_UNSTUB

setup() {
  export ROLLBAR_ACCESS_TOKEN="test-rollbar-token"
  export BUILDKITE_PLUGIN_ROLLBAR_DEPLOY_ENVIRONMENT="staging"
  export BUILDKITE_PLUGIN_ROLLBAR_DEPLOY_VERSION="7f62170bcd9090ee1909f3a55c6664eb8ec3a5be"
  export BUILDKITE_BUILD_URL="https://buildkite.com/my-org/my-pipeline/builds/12345"
  export BUILDKITE_JOB_ID="2a01c1e0-36e2-40bf-acee-f9801412a129"
}

call_hook_and_verify_stubs() {
  run "$PWD/hooks/command"

  for stubbed in "${_AUTO_UNSTUB[@]}"; do
    unstub "$stubbed"
  done
}

stub_api_call() {
  local method="$1"
  local deploy_id="$2"

  local status="${EXPECTED_STATUS:-${BUILDKITE_PLUGIN_ROLLBAR_DEPLOY_STATUS:-succeeded}}"
  local rollbar_username="${EXPECTED_ROLLBAR_USERNAME:-${ROLLBAR_USERNAME:-}}"
  local revision="${EXPECTED_VERSION:-${BUILDKITE_PLUGIN_ROLLBAR_DEPLOY_VERSION:-}}"
  local environment="${EXPECTED_ENVIRONMENT:-${BUILDKITE_PLUGIN_ROLLBAR_DEPLOY_ENVIRONMENT:-}}"
  local rollbar_access_token="${EXPECTED_ROLLBAR_ACCESS_TOKEN:-${ROLLBAR_ACCESS_TOKEN:-}}"
  local local_username="${EXPECTED_LOCAL_USERNAME:-${BUILDKITE_PLUGIN_ROLLBAR_DEPLOY_LOCAL_USERNAME:-}}"
  local comment

  if [[ -n "${EXPECTED_COMMENT+x}" ]]; then
    comment="$EXPECTED_COMMENT"
  else
    if [[ -n "${BUILDKITE_BUILD_URL:-}" ]]; then
      comment="Reported from Buildkite: ${BUILDKITE_BUILD_URL}"
      if [[ -n "${BUILDKITE_JOB_ID:-}" ]]; then
        comment="${comment}#${BUILDKITE_JOB_ID}"
      fi
    fi
  fi

  if [[ "$method" == "PATCH" ]]; then
    _EXPECTED_CURL_ARGS="-X ${method} 'https://api.rollbar.com/api/1/deploy/${deploy_id}' -H 'X-ROLLBAR-ACCESS-TOKEN: ${rollbar_access_token}' --form environment='${environment}' --form revision='${revision}' --form status='${status}' --form rollbar_username='${rollbar_username}' --form local_username='${local_username}' --form comment='${comment}'"
    _MOCK_RESPONSE_DATA="{\"result\": {\"id\": ${deploy_id}}}"
  else
    _EXPECTED_CURL_ARGS="-X ${method} 'https://api.rollbar.com/api/1/deploy/' -H 'X-ROLLBAR-ACCESS-TOKEN: ${rollbar_access_token}' --form environment='${environment}' --form revision='${revision}' --form status='${status}' --form rollbar_username='${rollbar_username}' --form local_username='${local_username}' --form comment='${comment}'"
    _MOCK_RESPONSE_DATA="{\"data\": {\"deploy_id\": ${deploy_id}}}"
  fi

  stub curl "${_EXPECTED_CURL_ARGS} : echo '${_MOCK_RESPONSE_DATA}'"
  _AUTO_UNSTUB+=( curl )
}

stub_metadata_deploy_id() {
  local deploy_id="$1"
  local metadata_key="${2:-$BUILDKITE_PLUGIN_ROLLBAR_DEPLOY_BUILDKITE_METADATA_DEPLOY_ID}"

  stub buildkite-agent \
    "meta-data exists '${metadata_key}' : true" \
    "meta-data get '${metadata_key}' : echo '${deploy_id}'" \
    "meta-data exists '${metadata_key}' : true"

  _AUTO_UNSTUB+=( buildkite-agent )
}

stub_no_metadata_deploy_id() {
  local expected_deploy_id="$1"
  local metadata_key="${2:-$BUILDKITE_PLUGIN_ROLLBAR_DEPLOY_BUILDKITE_METADATA_DEPLOY_ID}"

  stub buildkite-agent \
    "meta-data exists '${metadata_key}' : return 100" \
    "meta-data exists '${metadata_key}' : return 100" \
    "meta-data set '${metadata_key}' '${expected_deploy_id}' : true"

  _AUTO_UNSTUB+=( buildkite-agent )
}
