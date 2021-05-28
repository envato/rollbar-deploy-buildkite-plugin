# Create Datadog Event Buildkite Plugin

[Changelog] | [License (MIT)] | [Code of Conduct]

A [Buildkite plugin](https://buildkite.com/docs/agent/v3/plugins) which reports deployments to Rollbar. It contains a [command hook](hooks/command).

## Features

- Reports a deployment to Rollbar
- Supports the following features of the [official GitHub deploy action][official-action] as of version 2.0.0:
  - [x] Reporting a deployment
  - [x] Updating an existing deployment
  - [ ] Uploading source maps
- Supports passing `deploy_id` between steps via a new `buildkite_metadata.deploy_id` setting
- Includes a comment on the deploy, including the URL to the source Buildkite job

## Example

```yml
steps:
  # simple post-deploy report
  - env:
      ROLLBAR_ACCESS_TOKEN: $ROLLBAR_ACCESS_TOKEN
    plugins:
      - envato/rollbar-deploy#v1.0.0:
          environment: production
          version: $BUILDKITE_COMMIT
          status: succeeded


  # report started, then finished later
  - env:
      ROLLBAR_ACCESS_TOKEN: $ROLLBAR_ACCESS_TOKEN
    plugins:
      - envato/rollbar-deploy#v1.0.0:
          environment: production
          version: $BUILDKITE_COMMIT
          status: started
          local_username: $BUILDKITE_CREATOR
          buildkite_metadata:
            deploy_id: rollbar_deploy_id
  # deploy step here...
  - env:
      ROLLBAR_ACCESS_TOKEN: $ROLLBAR_ACCESS_TOKEN
    plugins:
      - envato/rollbar-deploy#v1.0.0:
          environment: production
          version: $BUILDKITE_COMMIT
          status: succeeded
          local_username: $BUILDKITE_CREATOR
          buildkite_metadata:
            deploy_id: rollbar_deploy_id
```

## Configuration

### Environment Variables

To maintain compability with the official GitHub actions plugin, the following values are obtained from environment variables:

| Required | Name      | Description |
| :------: | :-------- | :---------- |
|Y| `ROLLBAR_ACCESS_TOKEN` | Credentials used to report the deployment event. |
| | `DEPLOY_ID`            | Deploy ID used to update an existing deployment. Can be shared between steps via `buildkite_metadata` in plugin configuration instead. |
| | `ROLLBAR_USERNAME`     | Username of the associated Rollbar user. |

### Plugin Configuration

Most values correspond to the arguments in the [Post an event API].

| Required | Name      | Description |
| :------: | :-------- | :---------- |
|Y| `environment`    | The environment where the deploy is being done. |
|Y| `version`        | The version being deployed. |
| | `status`         | The status of the deploy. One of `started`, `succeeded` (default), `failed` or `timed_out`. |
| | `local_username` | Username of the deploying user, not associated to a Rollbar user. Alternative to setting `ROLLBAR_USERNAME`. |
| | `buildkite_metadata.deploy_id` | Metadata key used to pass a deploy ID for updates. Use the same value across multiple steps to update the existing deployment event. |

## License

MIT (see [LICENSE](LICENSE))

## Code of Conduct

Contributor Covenant 2.0 (see [CODE_OF_CONDUCT](CODE_OF_CONDUCT.md))

## Maintainers

- [Liam Dawson](https://github.com/liamdawson/)

## About

This project is maintained by the [Envato engineering team][webuild] and funded by [Envato][envato].

[![Envato logo](https://opensource.envato.com/images/envato-oss-readme-logo.png)][envato]

Encouraging the use and creation of open source software is one of the ways we serve our community. See [our other projects][oss] or [come work with us][careers] where you'll find an incredibly diverse, intelligent and capable group of people who help make our company succeed and make our workplace fun, friendly and happy.

  [official-action]: https://github.com/rollbar/github-deploy-action
  [Changelog]: CHANGELOG.md
  [License (MIT)]: LICENSE
  [Code of Conduct]: CODE_OF_CONDUCT.md
  [webuild]: http://webuild.envato.com?utm_source=github
  [envato]: https://envato.com?utm_source=github
  [oss]: http://opensource.envato.com//?utm_source=github
  [careers]: http://careers.envato.com/?utm_source=github
