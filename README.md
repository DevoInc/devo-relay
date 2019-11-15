# Relay In House Docker

Devo Relay scoja based docker project

Project to deploy a Relay using docker without to be necessary install anything.

To connect to relay just send your event to localhost at default ports 12999/13002

The compose is ready to share ports from 12999 to 13030 to cover more needs than default ports

The first time when your run the docker Relay, remember to active the relay in Devo Website

Clone or [download](https://github.com/DevoInc/devo-relay/archive/master.zip) the repository.

Be sure that [conf/docker-start](./conf/docker-start) has executable permissions after uncompress or clone the repository

## Needs to run relay: (Modify in docker-devo-relay.yml)
1. LOGTRUST_WEB = https://eu.devo.com | https://us.devo.com | https://es.devo.com | ...
2. LOGTRUST_ENDPOINT = eu.elb.relay.logtrust.net | us.elb.relay.logtrust.net | ...
3. RELAY_NAME = The_name_for_your_relay
4. RELAY_APIKEY = YOUR_API_KEY from your domain when you want to send events

## Run and Stop docker Relay

1. Run: `DCKHUB=devoinc/ docker-compose -f docker-devo-relay.yml up -d`
2. Stop: `docker-compose -f docker-devo-relay.yml down`

## Tips and tricks

1. Check relay using simple command
    1. for i in $( seq 150 ) ; do echo "<14>$( date --iso-8601=seconds ) docker-relay test.keep.free: Docker Devo-Relay test event # $i" | nc -N localhost 13000 ; done
    2. Check your test.keep.free table to see the events

2. HowTo connect the container
    1. docker exec -it Devo-Relay /bin/bash

3. Run relay without compose and without to use this repository:
    1. `docker run -it -p 12999-13030:12999-13030 -e LOGTRUST_WEB=https://eu.devo.com -e LOGTRUST_ENDPOINT=eu.elb.relay.logtrust.net -e RELAY_NAME=docker-relay-domain_name -e RELAY_APIKEY=YOUR_API_KEY --name Devo-Relay -v "$your_path_keys:/etc/logtrust/scoja/current/keys" -v "$your_path_logs:/var/log" -v "$your_path_relay-data:/opt/devo/relay-data" -v "$your_path_rules:/etc/logtrust/scoja/current/rules" -v "$your_path_unrules:/etc/logtrust/scoja/current/unrules" devoinc/devo-relay:1.1.6 /opt/devo/run/docker-start`
    2. Set correct values for:
        1. LOGTRUST_WEB
        2. LOGTRUST_ENDPOINT
        3. RELAY_NAME
        4. RELAY_APIKEY
        5. $your_path_xxx (absolute path required)

4. You can download the image using: `docker pull devoinc/devo-relay:1.1.6`

## Author

jordilobo | [jordi.lobo@devo.com](mailto:jordi.lobo@devo.com)

## Contact Us
You can contact with us at support@devo.com.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

#### Enjoy it
