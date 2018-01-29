# bosh-cron

Provides basic cron scheduling functionality.

## Cron item configuration

```
$ bosh update-config cron-item item.yml --name cf-smoke-tests
```

```yaml
schedule: "@hourly"
errand:
  name: smoke-tests
  instances: [first]
  keep_alive: true
include:
  deployments:
  - cf
```

Schema:

- `schedule` (string) is defined by https://godoc.org/gopkg.in/robfig/cron.v2#hdr-Predefined_schedules.

- `errand` (hash) to run an errand:

```yaml
schedule: "@hourly"
errand:
  name: smoke-tests
  instances: [group/id, group/first]
  when_changed: false
  keep_alive: true
```

- `cleanup` (hash) to run clean up Director task:

```yaml
schedule: "@weekly"
cleanup: {}
```

- `include` (hash) specifies which deployments to apply this item to (if none specified all current deployments are selected; currently only used with errands):

```yaml
include:
  deployments:
  - name1
  - name2
```

- `run_once` (boolean) indicates whether to delete this item after its first run.

## Cron item status

Each cron item will have its status reported under same named `cron-status` type config:

```
$ bosh config cron-item-status --name cf-smoke-tests
```

```yaml
started_at: "2017..."
finished_at: "2017..."
successful: true
error: ...
errand:
  task_id: 123
  exit_code: ...
```

## Cron status

General cron status is reported under `cron-status` type config:

```
$ bosh config cron-status
```

```yaml
reloaded_at: "2017..."
successful: false
errors:
- ...
```

## Deploy

```
$ bosh -e vbox -d bosh-cron -n deploy manifests/example.yml \
  -v director_ip=192.168.56.6 \
  --var-file director_ssl.ca=<(bosh int ~/workspace/deployments/vbox/creds.yml --path /director_ssl/ca) \
  -v director_client=admin \
  -v director_client_secret=`bosh int ~/workspace/deployments/vbox/creds.yml --path /admin_password` \
  -o manifests/dev.yml
```

## Development

Unit tests: `./src/github.com/bosh-tools/bosh-cron/bin/test`

## TODO

- additional jobs
  - stemcell updating
  - any bosh cli command
- explicit config validation?
- generic status api?
- dont track history for status configs?
- team namespacing
- use bosh api to filter deployments
- running multiple cron instances?
- generic cli commands?
