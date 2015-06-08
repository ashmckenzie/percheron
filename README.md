# Percheron

[![Gem Version](https://badge.fury.io/rb/percheron.svg)](http://badge.fury.io/rb/percheron)
[![Build Status](https://travis-ci.org/ashmckenzie/percheron.svg?branch=master)](https://travis-ci.org/ashmckenzie/percheron)
[![Code Climate GPA](https://codeclimate.com/github/ashmckenzie/percheron/badges/gpa.svg)](https://codeclimate.com/github/ashmckenzie/percheron)
[![Test Coverage](https://codeclimate.com/github/ashmckenzie/percheron/badges/coverage.svg)](https://codeclimate.com/github/ashmckenzie/percheron)
[![Dependency Status](https://gemnasium.com/ashmckenzie/percheron.svg)](https://gemnasium.com/ashmckenzie/percheron)

![Percheron logo](./percheron-logo.png)

### Organise your Docker containers with muscle and intelligence.

## Why?

Percheron aims to address the following challenges when working with Docker images and containers:

* Managing multiple containers and mutiple sets (stacks) of containers
* Building images and containers with support for dependencies
* Versioning of images and containers

Percheron is like Vagrant but instead of managing VM's, it manages Docker images and containers.
It is a very handy tool when you wish to create a basic or complex stack without the need to run
multiple VMs.

It is intended to be used in a test, development or prototyping scenario.

## Features

* Single, easy to write `.percheron.yml` describes your stack(s)
* Build, create and start units and their dependencies
* Build units using a Dockerfile or by pulling Docker images from Docker Hub
* Build 'bare/base' images and build new images on top of them
* Support for pre-build and post-start scripts when generating images and starting units
* Version control of images and units
* Partial template (liquid) support within `.percheron.yml`
* Generate Graphviz dependency graphs dynamically based purely on your `.percheron.yml`
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

```
Usage:
    percheron [OPTIONS] SUBCOMMAND [ARG] ...

Parameters:
    SUBCOMMAND                    subcommand
    [ARG] ...                     subcommand arguments

Subcommands:
    list, status                  List stacks and its units
    console                       Start a pry console session
    start                         Start a stack
    stop                          Stop a stack
    restart                       Restart a stack
    build                         Build images for a stack
    create                        Build images and create units for a stack
    recreate                      Recreate a stack
    purge                         Purge a stack
    shell                         Shell into a unit
    logs                          Show logs for a unit
    graph                         Generate a stack graph

Options:
    -h, --help                    print help
    -c, --config_file CONFIG      Config file (default: ".percheron.yml")
    --version                     show version
```

## Demo (using boot2docker)

1) Get boot2docker up and running

```bash
boot2docker up && eval $(boot2docker shellinit) && export BOOT2DOCKER_IP=$(boot2docker ip)
```

2) Install percheron

```bash
gem install percheron
```

3) Create a `.percheron.yml` file describing the stack, in this case [consul](https://consul.io/):

```yaml
---
docker:
  host: "https://boot2docker:2376"
  ssl_verify_peer: false

stacks:
  - name: consul-stack
    description: A demo consul stack with one master and two agents
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
        instances: 2
        docker_image: progrium/consul:latest
        start_args: "-server -join master"
        dependant_unit_names:
          - master
```

4) Start it up!

```bash
percheron start consul-stack

I, [2015-05-21T19:25:05.975964 #35449]  INFO -- : Starting 'master' unit
I, [2015-05-21T19:25:06.676782 #35449]  INFO -- : Starting 'agent1' unit
I, [2015-05-21T19:25:07.167997 #35449]  INFO -- : Starting 'agent2' unit
```

5) Show the status

```bash
percheron status consul-stack

+--------+--------------+----------+------------+------------------------+---------+---------+
|                                        consul-stack                                        |
+--------+--------------+----------+------------+------------------------+---------+---------+
| Unit   | ID           | Running? | IP         | Ports                  | Volumes | Version |
+--------+--------------+----------+------------+------------------------+---------+---------+
| master | 0acd1e2cfbc0 | yes      | 172.17.0.1 | 8500:8500, 8600:53/udp |         | 1.0.0   |
| agent1 | d70495c1c62b | yes      | 172.17.0.2 |                        |         | 1.0.0   |
| agent2 | 458ad3ba0890 | yes      | 172.17.0.3 |                        |         | 1.0.0   |
+--------+--------------+----------+------------+------------------------+---------+---------+
```

6) Ensure consul is running

```bash
curl http://boot2docker:8500/v1/catalog/nodes

[{"Node":"agent1","Address":"172.17.0.5"},{"Node":"agent2","Address":"172.17.0.6"},{"Node":"master","Address":"172.17.0.4"}]
```

7) Perform some DNS lookups using consul

```bash
dig @boot2docker -p 8600 master.node.consul agent1.node.consul agent2.node.consul +short

172.17.0.7
172.17.0.8
172.17.0.9
```

8) Bring up the consul UI

```bash
open http://boot2docker:8500/ui
```

9) Purge it!

```bash
percheron purge consul-stack

I, [2015-05-21T19:28:23.925205 #35710]  INFO -- : Stopping 'agent2' unit
I, [2015-05-21T19:28:24.269218 #35710]  INFO -- : Deleting 'agent2' unit
I, [2015-05-21T19:28:24.452320 #35710]  INFO -- : Stopping 'agent1' unit
I, [2015-05-21T19:28:24.811764 #35710]  INFO -- : Deleting 'agent1' unit
I, [2015-05-21T19:28:24.965680 #35710]  INFO -- : Stopping 'master' unit
I, [2015-05-21T19:28:25.246578 #35710]  INFO -- : Deleting 'master' unit
```

## Dependency graph

Note: Requires [Graphviz](http://graphviz.org/) installed.

```bash
percheron graph consul-stack
```

![consul-stack](https://raw.githubusercontent.com/ashmckenzie/percheron-consul/master/assets/stack.png)

## Demo asciicast

[![asciicast](https://asciinema.org/a/7l1ar35xlmfsaphhptrqvx7jg.png)](https://asciinema.org/a/7l1ar35xlmfsaphhptrqvx7jg)

## Debugging

To perform debugging you will need to install the `pry-byebug` gem:

```bash
gem install pry-byebug
```

To debug Percheron, set the `DEBUG=true` environment variable.

To debug Percheron and Docker, set the `DOCKER_DEBUG=true` environment variable.

## Examples

* [consul](https://github.com/ashmckenzie/percheron-consul) - consul server + UI and two agents
* [Rails](https://github.com/ashmckenzie/percheron-rails#quickstart) - Rails 4.2, PostgreSQL, redis, HAProxy and postfix
* [Redis](https://github.com/ashmckenzie/percheron-redis#quickstart) - Redis cluster + sentinel, master, two slaves and tools
* [Torrent](https://github.com/ashmckenzie/percheron-torrent#quickstart) - Tracker (chihaya), seeder (aria2) and three peers (aria2)
* [SaltStack](https://github.com/ashmckenzie/percheron-saltstack#quickstart) - SaltStack v2015.5.0 with master and two minions

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
