# Upgrading the Devo NG-Relay correctly

Follow this guide every time you change `DEVO_NG_RELAY_VERSION`, and especially
for major upgrades such as `2.x` to `3.x` (for example `2.13.3` to `3.1.1`).
Run every command from the folder that contains `docker-compose.yml`.

> If your host uses Docker Compose v2, write `docker compose` (with a space)
> instead of `docker-compose`. The commands are otherwise the same.

> The files in `conf/` belong to the relay's container user (uid 2000) and most
> of them are not readable by other users, so the file commands in this guide
> (`tar`, `rm`, `mv`, `grep`) use `sudo`. Running `tar` as root also keeps the original
> owners when you restore a backup, so the relay can still read its files.

## Why there is an extra step

Your relay configuration lives in the `conf/` folder on the host. Changing the
version in `.env` updates the relay engine, but **not** the scripts in
`conf/relay/run/static/`. If those scripts stay on the old version, the new
engine turns RFC5424 parsing on, and RFC3164 sources such as Meraki can end up
in `unknown.unknown`.

The upgrade steps below refresh `static/` so it matches the new engine.

## Upgrade

> **Plan a maintenance window.** From `docker-compose down` (step 1) until
> the relay starts again in step 4, the relay is stopped and its ports
> are closed, so no events are received or sent to Devo. This usually takes a
> few minutes.
>
> - Events sent over **UDP** during that time are lost.
> - Events sent over **TCP** are lost unless the sending device queues and
>   resends them; check your devices.
> - Events the relay had already received are kept in the disk buffer and are
>   sent to Devo after the restart.

### Get the latest files

Each release of this repository updates `docker-compose.yml` and sets the new
relay version in `.env`. Pull it, keeping any changes you made to `.env` (such as
`JAVA_OPTS` or the port ranges):

```bash
git stash        # set aside your local changes
git pull
git stash pop    # put your changes back
```

If `git stash` printed `No local changes to save`, skip `git stash pop`.

If `git stash pop` reports a conflict in `.env`, open the file, keep the new
`DEVO_NG_RELAY_VERSION` line plus your own settings, and remove the conflict
markers (`<<<<<<<`, `=======`, `>>>>>>>`).

Then check which version will be installed:

```bash
grep DEVO_NG_RELAY_VERSION .env
```

To install a different version, edit that line before continuing. The commands
below use whatever version is set there; if it still shows your old version,
they will reinstall the old version instead of upgrading.

### Run the upgrade

```bash
# 1. Stop the relay
docker-compose down

# 2. Back up your whole configuration (just in case)
sudo tar czf conf-backup.tgz conf

# 3. Refresh static/ from the new image
#    (your current static/ is saved to conf/relay/run/static.bak)
docker-compose run --rm devo-ng-relay-static-sync

# 4. Recreate the relay on the new image and open the CLI
docker-compose run --rm devo-ng-relay-cli
```

Run step 3 before step 4. The CLI starts the relay, so if it runs first the
new engine starts with the old `static/`. When you exit the CLI, the relay keeps
running.

### Check that it worked

In the CLI opened by step 4, run `test`:

```
DEVO-RELAY:> test
Sending test data to the relay...
Retrieving the test data using the query API...

---> SUCCESS Test successful. The relay is working correctly.
```

The command sends a test event through the relay and reads it back from Devo.
If it does not print `SUCCESS`, see [Rollback](#rollback).

You can also check from the shell:

```bash
# Should print a number greater than 0
sudo grep -c isRFC5424Supported conf/relay/run/static/dsl_extensions/common.py

# The relay should be running
docker-compose ps
```

Then confirm in Devo that events are arriving in the expected tables.

## What changes and what is kept

**Replaced:** the whole `conf/relay/run/static/` folder. If you edited any file
in there, your old copy is in `conf/relay/run/static.bak`.

**Kept as is:**

- `relay.properties`
- `keys/`
- `rules/` and `unrules/`
- `custom.py` (if it is missing, the 3.x default is added)
- the disk buffer and logs

`run/local.py` is rebuilt from the template when the relay starts, so manual
edits to it are lost. Put persistent settings in `custom.py` instead.

## RFC5424 settings

RFC5424 and octet counting are **off** by default in 3.x. Leave them off for
RFC3164 sources such as Meraki. To turn them on, edit
`conf/relay/run/custom.py`:

```bash
sudo vi conf/relay/run/custom.py
```

and set:

```python
rfc5424_enabled = True
octet_counting_enabled = True
```

Then restart the relay so it reads the new values:

```bash
docker-compose restart devo-ng-relay
```

The relay log confirms the values at startup:

```bash
docker-compose logs devo-ng-relay | grep custom.py
```

```
Maduro : custom.py: octet_counting_enabled: True
Maduro : custom.py: rfc5424_enabled: True
```

If you came from 3.0.x and `custom.py` already has `rfc5424_enabled = True`,
RFC5424 stays on after the upgrade. Change it to `False` if your sources send
RFC3164.

## Rollback

Rollback also stops the relay until it is started again, with the same impact
on ingestion as the upgrade.

1. Set `DEVO_NG_RELAY_VERSION` in `.env` back to the version you were running
   before the upgrade:

   ```
   DEVO_NG_RELAY_VERSION = <old version>
   ```

2. Restore the old `static/` and start the relay:

   ```bash
   docker-compose down
   sudo rm -rf conf/relay/run/static
   sudo mv conf/relay/run/static.bak conf/relay/run/static
   docker-compose run --rm devo-ng-relay-cli
   ```

Do **not** run `static-sync` after restoring, because it would overwrite the
restored files. If something else went wrong, restore the full backup instead:

```bash
docker-compose down
sudo rm -rf conf
sudo tar xzf conf-backup.tgz
docker-compose run --rm devo-ng-relay-cli
```

## Cleanup

Once the relay is healthy and events are landing in the right tables, you can
delete the backups:

```bash
sudo rm -rf conf/relay/run/static.bak conf-backup.tgz
```

## "no such service: devo-ng-relay-static-sync"

Your `docker-compose.yml` is older than this guide. Go back to
[Get the latest files](#get-the-latest-files). If you did not install the relay
with `git clone`, download the latest `docker-compose.yml` from this repository
and replace yours with it; your relay configuration is in `conf/` and is not
affected.
