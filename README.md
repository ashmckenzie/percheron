# Percheron

[![Gem Version](https://badge.fury.io/rb/percheron.svg)](http://badge.fury.io/rb/percheron)
[![Build Status](https://travis-ci.org/ashmckenzie/percheron.svg?branch=master)](https://travis-ci.org/ashmckenzie/percheron)
[![Code Climate GPA](https://codeclimate.com/github/ashmckenzie/percheron/badges/gpa.svg)](https://codeclimate.com/github/ashmckenzie/percheron)
[![Test Coverage](https://codeclimate.com/github/ashmckenzie/percheron/badges/coverage.svg)](https://codeclimate.com/github/ashmckenzie/percheron)
[![Dependency Status](https://gemnasium.com/ashmckenzie/percheron.svg)](https://gemnasium.com/ashmckenzie/percheron)

Organise your Docker containers with muscle and intelligence.

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

TODO

## Examples

* [Rails](https://github.com/ashmckenzie/percheron-rails#quickstart) - Rails 4.2, PostgreSQL, redis, HAProxy and postfix
* [Torrent](https://github.com/ashmckenzie/percheron-torrent#quickstart) - Tracker (chihaya), seeder (aria2) and three peers (aria2)
* SaltStack - https://github.com/ashmckenzie/percheron-saltstack#quickstart - SaltStack v2015.2.0rc2 with master and minion

## Testing

All (cane, RuboCop, unit and integration):

```shell
bundle exec test
```

Style (cane and RuboCop):

```shell
bundle exec test:style
```

## Contributing

1. Fork it ( https://github.com/ashmckenzie/percheron/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Run `bundle exec rake test`
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
