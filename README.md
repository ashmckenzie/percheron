# Percheron

[![Gem Version](https://badge.fury.io/rb/percheron.svg)](http://badge.fury.io/rb/percheron)
[![Build Status](https://travis-ci.org/ashmckenzie/percheron.svg?branch=master)](https://travis-ci.org/ashmckenzie/percheron)
[![Code Climate GPA](https://codeclimate.com/github/ashmckenzie/percheron/badges/gpa.svg)](https://codeclimate.com/github/ashmckenzie/percheron)
[![Test Coverage](https://codeclimate.com/github/ashmckenzie/percheron/badges/coverage.svg)](https://codeclimate.com/github/ashmckenzie/percheron)
[![Dependency Status](https://gemnasium.com/ashmckenzie/percheron.svg)](https://gemnasium.com/ashmckenzie/percheron)

Organise your Docker containers with muscle and intelligence.

## Features

* Single, easy to write `.percheron.yml` controls everything
* Supports building, creating and starting of containers and their dependancies
* Supports building using a Dockerfile or pulling a Docker image from Docker Hub
* Build 'base' images as a dependancy and then build from there
* Support for pre-build and post-start scripts when generating images and starting containers
* Version control of building images and containers
* Written in Ruby :)

## Supported platforms

* Linux
* MacOS 10.9+

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'percheron'
```

And then execute:

```shell
$ bundle install
```

Or install it yourself as:

```shell
$ gem install percheron
```

## Requirements

* Ruby 2.x
* [Docker 1.6.x](https://docs.docker.com/installation/) / [Boot2Docker v1.6.x+](https://docs.docker.com/installation)
* [Docker client](https://docs.docker.com/installation) (nice to have)

## Usage

1) Install percheron

```bash
gem install percheron
```

2) Create a `.percheron.yml` file describing your stack:

```yaml
---
docker:
  host: "https://boot2docker:2376"
  ssl_verify_peer: false

stacks:
  - name: consul-stack
    units:
      - name: master
        version: 1.0.0
        docker_image: progrium/consul:latest
        start_args: "-server -bootstrap -ui-dir /ui"
        ports:
          - 8500:8500
          - 8600:53/udp
      - name: agent
        version: 1.0.0
        docker_image: progrium/consul:latest
        start_args: "-server -join master"
        dependant_unit_names:
          - master
```

3) Start it up!

```bash
percheron start consul-stack
```

4) Bring up the consul UI

```bash
open http://boot2docker:8500/ui
```

5) Perform a DNS lookup

```bash
dig @boot2docker -p 8600 master.node.consul +short
```

## Demo

[![asciicast](https://asciinema.org/a/bs09umip9wdozy26ylbd7d26o.png)](https://asciinema.org/a/bs09umip9wdozy26ylbd7d26o)

## Debugging

To perform debugging you will need to install the `pry-byebug` gem:

```bash
gem install pry-byebug
```

To debug Percheron, set the `DEBUG=true` environment variable.  To debug Percheron and Docker, set the `DOCKER_DEBUG=true` environment variable.

## Examples

* [Rails](https://github.com/ashmckenzie/percheron-rails#quickstart) - Rails 4.2, PostgreSQL, redis, HAProxy and postfix
* [Redis](https://github.com/ashmckenzie/percheron-redis#quickstart) - Redis cluster + sentinel, master, two slaves and tools
* [Torrent](https://github.com/ashmckenzie/percheron-torrent#quickstart) - Tracker (chihaya), seeder (aria2) and three peers (aria2)
* [SaltStack](https://github.com/ashmckenzie/percheron-saltstack#quickstart) - SaltStack v2015.2.0rc2 with master and minion

## Testing

All (cane, RuboCop, unit and integration):

```shell
bundle exec rake test
```

Style (cane and RuboCop):

```shell
bundle exec rake test:style
```

## Contributing

1. Fork it ( https://github.com/ashmckenzie/percheron/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Run `bundle exec rake test`
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
