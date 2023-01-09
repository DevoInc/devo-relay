# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.4.0] -

- devo-ng-relay v2.3.1
- devo-ng-relay-cli v1.2.4

## [1.3.0] - 2022-09-13

- devo-ng-relay v2.2.3
- devo-ng-relay-cli v1.2.2

## [1.2.1] - 2022-07-19

- In docker compose V2 there is an [issue](https://github.com/docker/compose/issues/9410) 
that was fixed in V1, but has been replicated again, so relative paths in named volumes 
don't work. We have added a workaround until it gets fixed by docker compose team.

## [1.2.0] - 2022-05-20

- devo-ng-relay-cli v1.1.0
- devo-ng-relay v2.1.0

## [1.1.0] - 2022-02-01

- devo-ng-relay v2.0.3

## [1.0.0] - 2021-08-13

### Added 

- Initial version of the docker-compose for the Devo NG-Relay.
- .env file to decouple the compose file.
