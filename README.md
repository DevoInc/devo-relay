# NG-Relay Docker Compose

This repository contains an example of how to run the Devo NG-Relay and Devo
NG-Relay CLI together with [docker compose](https://github.com/docker/compose).
It is not mandatory, but recommended, to run both applications.

## Requirements

To use this docker-compose file the following requirements must be met:

* docker-compose version: [v1.27+](https://github.com/docker/compose/releases)
* the following folders **must exist at the same level as *docker-compose.yaml*
  file**:
    * *conf*: Stores the NG-Relay configuration. The first time the Devo NG-Relay
      is run, a default configuration is populated to this folder. Once the default
      configuration is populated, the subsequent times the Devo NG-Relay is run
      nothing will be populated unless the folder is empty.
    * *buffer*: Stores the Devo NG-Relay buffer.
    * *logs*: Stores the Devo NG-Relay logs.
* All the above folders must have *write* and *execute* permissions for *others*.

An example of the last two points may be:

```bash
# Create the folders
mkdir conf buffer logs

# Grant write and execution for 'others'
sudo chmod 777 conf/ buffer/ logs/
```

## Environment

To work with this docker-compose file, some environment variables need to be
set. For this purpose, there is an environment file `.env` in which you can set
them. There is a short description of each of them below:

| Name                  | Mandatory | Default Value | Description |
| --------------------- | :-------: | :-----------: | ----------- |
| NG_RELAY_VERSION      | Yes       | 2.0.1         | Version of the Devo NG-Relay. |
| LOG_LEVEL             | No        | info          | Sets the log level for the Devo NG-Relay. |
| JAVA_OPTS             | No        | -Xmx1G -Xms1G | Space-separated quoted list in which you can activate/deactivate any of the JVM flags. |
| TCP_PORT_RANGE        | No        | 13003-13020   | Used to open the TCP ports specified in all the user-defined rules. |
| UDP_PORT_RANGE        | No        | 13003-13020   | Used to open the UDP ports specified in all the user-defined rules. |
| NG_RELAY_CLI_VERSION  | Yes       | 1.0.0         | Version of the Devo NG-Relay CLI. |

## Quick Start

The recommended way to launch this docker-compose is executing the following
command:

```bash
docker-compose run -rm devo-ng-relay-cli
```

The command above will run the Devo NG-Relay and the Devo NG-Relay CLI and will
present the prompt of the Devo NG-Relay CLI waiting for commands to run.

If you only want to launch the Devo NG-Relay, you can try one of the following
commands:

* Attached mode:
  ```bash
  docker-compose up devo-ng-relay
  ```

* Detached mode:
  ```bash
  docker-compose up -d devo-ng-relay
  ```
If you encounter any problem, refer to the [Troubleshooting](#Troubleshooting)
section.

## Troubleshooting

### Devo NG-Relay CLI cannot connect to Devo NG-Relay

Often, the first time this docker-compose is launched we might see the following
message:

```
***************************
APPLICATION FAILED TO START
***************************

Description:

Error connecting to devo-ng-relay:12998

Action:

Consider launching the application with the following arguments:
        --host=<HOST>
        --port=<PORT>

ERROR: 1

```
This occurs because the Devo NG-Relay is not fully started when the Devo
NG-Relay CLI started. To solve this, simply re-run the command below:

```bash
docker-compose run -rm devo-ng-relay-cli
```

### When I modify an environment variable the changes are not reflected to the container

After an environment variable is changed the Devo NG-Relay container needs to be
re-created. To do so, just execute:

```bash
docker-compose up [-d] devo-ng-relay
```

### Error creating volume

You might see an error similar to the following if the folders for the volumes
are not created:

```
Creating network "xxxx_default" with the default driver
Creating devo-ng-relay ... error
Creating volume "xxxx_conf" with local driver
ERROR: for devo-ng-relay  Cannot create container for service devo-ng-relay: failed to mount local volume: mount /<your_conf_path>:/var/lib/docker/volumes/xxxx_conf/_data, flags: 0x1000: no such file or directory
```

If this happens to you, please refer to the [Requirements](#Requirements)
section and ensure that the folders have been created correctly.

### After configuring a new relay I see exceptions thrown in the logs

An example of this kind of errors is the following:

```
devo-ng-relay        | Aug  5 09:51:22 57b09a9df2e3 syslog.scoja.configuration: While (re)loading "/opt/devo/ng-relay/conf/relay/run/me.conf": org.scoja.common.ConfigurationException: Error while interpreting configuration file "/opt/devo/ng-relay/conf/relay/run/me.conf": Traceback (most recent call last):
devo-ng-relay        |   File "/opt/devo/ng-relay/conf/relay/run/me.conf", line 10, in <module>
devo-ng-relay        |     trans = outTransports(
devo-ng-relay        |   File "/opt/devo/ng-relay/conf/relay/run/defs.py", line 113, in outTransports
devo-ng-relay        |     buf = diskfall(
devo-ng-relay        |   File "<scoja language definition>", line 550, in diskfall
devo-ng-relay        | 	at sun.nio.fs.UnixException.translateToIOException(UnixException.java:84)
devo-ng-relay        | 	at sun.nio.fs.UnixException.rethrowAsIOException(UnixException.java:102)
devo-ng-relay        | 	at sun.nio.fs.UnixException.rethrowAsIOException(UnixException.java:107)
devo-ng-relay        | 	at sun.nio.fs.UnixFileSystemProvider.createDirectory(UnixFileSystemProvider.java:384)
devo-ng-relay        | 	at java.nio.file.Files.createDirectory(Files.java:674)
devo-ng-relay        | 	at java.nio.file.Files.createAndCheckIsDirectory(Files.java:781)
devo-ng-relay        | 	at java.nio.file.Files.createDirectories(Files.java:767)
devo-ng-relay        | 	at org.scoja.util.diskqueue.FilePairQueue.open(FilePairQueue.java:111)
devo-ng-relay        | 	at org.scoja.util.diskqueue.FilePairFall.<init>(FilePairFall.java:22)
devo-ng-relay        | 	at sun.reflect.NativeConstructorAccessorImpl.newInstance0(Native Method)
devo-ng-relay        | 	at sun.reflect.NativeConstructorAccessorImpl.newInstance(NativeConstructorAccessorImpl.java:62)
devo-ng-relay        | 	at sun.reflect.DelegatingConstructorAccessorImpl.newInstance(DelegatingConstructorAccessorImpl.java:45)
devo-ng-relay        | 	at java.lang.reflect.Constructor.newInstance(Constructor.java:423)
devo-ng-relay        | 	at org.python.core.PyReflectedConstructor.constructProxy(PyReflectedConstructor.java:213)
devo-ng-relay        | java.nio.file.AccessDeniedException: java.nio.file.AccessDeniedException: /var/logt/buffer/me
```

To solve this, ensure the volume folders have the right permissions. Please
refer to the [Requirements](#Requirements) section for this matter.

### Ask for help

For an extra guidance or to further support, contact to <support@devo.com>.

## Useful commands

Below there are some useful commands to work with this docker-compose file.

### Start the Devo NG-Relay and Devo NG-Relay CLI

```bash
docker-compose run -rm devo-ng-relay-cli
```

### Start the Devo NG-Relay only

```bash
docker-compose up [-d] devo-ng-relay
```

### View the Devo NG-Relay logs

```bash
docker-compose logs -f devo-ng-relay
```

### Display information about the status and ports of containers started with this file

```bash
docker-compose ps -a
```

### Stop and destroy all the containers

```bash
docker-compose down
```

### Enter into the Devo NG-Relay container

```bash
docker exec -it devo-ng-relay bash
```

## Links

[Devo](https://www.devo.com/)

[Devo NG-Relay documentation](https://docs.devo.com/confluence/ndt/latest/sending-data-to-devo)

[Devo in DockerHub](https://hub.docker.com/u/devoinc)

## Follow us

[Twitter](https://twitter.com/devo_inc)

[Youtube](https://www.youtube.com/channel/UCC8gq9iZiHkZMcdztzqHP8Q)

[LinkedIn](https://www.linkedin.com/company/devoinc/)
