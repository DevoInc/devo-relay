# NG-Relay Docker Compose

This repository contains an example of how to run the Devo NG-Relay and Devo
NG-Relay CLI together with [docker compose](https://github.com/docker/compose).
It is not mandatory, but recommended, to run both applications.

* [Requirements](#Requirements)
* [Preparation](#Preparation)
* [Start the relay](#Start-the-relay)
* [Stop the relay](#Stop-the-relay)
* [Check the relay logs](#Check-the-relay-logs)
* [Troubleshooting](#Troubleshooting)
* [Useful commands](#Useful-commands)

## Requirements

Make sure you can provide a host machine with the requirements specified in [this article](https://docs.devo.com/confluence/ndt/v7.7.0/sending-data-to-devo/devo-relay/planning-devo-relay-deployment).

As we will use docker to run the relay, the following additional requirements have to be met:
* docker-compose version: [v1.27+](https://github.com/docker/compose/releases)

## Preparation

* Clone this repo in the machine where you want to install the relay

* Create new folders for config, local logs, and disk buffer in the same folder where the `docker-compose.yml` file is located.

```bash
mkdir conf buffer logs
```

* All the above folders must have *write* and *execute* permissions for *others*.

```bash
sudo chmod 777 conf/ buffer/ logs/
```

* Edit the environment file

To work with this docker-compose file, some environment variables need to be
set. For this purpose, there is an environment file `.env` in which you can set
them. There is a short description of each of them below:

| Name                  | Mandatory | Default Value | Description |
| --------------------- | :-------: | :-----------: | ----------- |
| LOG_LEVEL             | No        | info          | Sets the log level for the Devo NG-Relay. |
| JAVA_OPTS             | No        | -Xmx1G -Xms1G | Space-separated quoted list in which you can activate/deactivate any of the JVM flags. |
| TCP_PORT_RANGE        | No        | 13003-13020   | Used to open the TCP ports specified in all the user-defined rules. |
| UDP_PORT_RANGE        | No        | 13003-13020   | Used to open the UDP ports specified in all the user-defined rules. |

## Start the relay

The recommended way to launch this docker-compose is executing the following
command:

```bash
docker-compose run --rm devo-ng-relay-cli
```

> The command above will run the Devo NG-Relay and the Devo NG-Relay CLI and will
present the prompt of the Devo NG-Relay CLI waiting for commands to run. You can type exit when you are done with the CLI. The relay container will continue up and running. 

> The first time a relay is started, you will have to perform the setup process using the CLI. To do it, follow the steps indicated in [Set up your relay](https://docs.devo.com/confluence/ndt/v7.7.0/sending-data-to-devo/devo-relay/configuring-devo-relay/configuring-devo-relay-on-the-linux-command-line/set-up-your-relay).

If you encounter any problem, refer to the [Troubleshooting](#Troubleshooting)
section.

## Stop the relay

To stop and destroy all the containers and networks created before, run the following command:

```bash
docker-compose down
```

> Note that the relay configuration will remain available as it is stored outside the containers. Using the start command above will start the relay again using the existing configuration. 

## Check the relay logs

To check the relay container logs, use this command:

```bash
docker-compose logs -f devo-ng-relay
```

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
docker-compose run --rm devo-ng-relay-cli
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

### Failed to mount local volume error

A very similar issue to the one before is this error:

```
Error response from daemon: failed to mount local volume: 
mount ./conf:/var/lib/docker/volumes/xxxx_conf/_data, flags: 0x1000: no such file or directory
```

This may happen to you if this docker-compose file is run by using the new
`Compose V2`. If that is the case, please update this project to `1.2.1+`, at
least, and re-run the docker compose file.

There is several bugs related to this issue on Github for docker compose V2 
([link](https://github.com/docker/compose/issues?q=is%3Aopen+label%3A%22Docker+Compose+V2%22+Relative)).

**NOTE**: Depending on the shell you are running this compose file, it may or
may not be necessary to export a variable called `PWD` pointing to the path
where the volumes are located prior to run the docker compose. For example:

```
export PWD=$(pwd)                           # PWD points to the current dir
docker compose run --rm devo-ng-relay-cli   # Start the docker compose
```

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
docker-compose run --rm devo-ng-relay-cli
```

### Start the Devo NG-Relay only

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
