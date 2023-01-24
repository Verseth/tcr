# TCR revived (TCP + VCR)

[![license](https://img.shields.io/badge/License-MIT-purple.svg)](LICENSE)
[![CI badge](https://github.com/Verseth/tcr_revived/actions/workflows/ci_ruby.yml/badge.svg)](https://github.com/Verseth/tcr_revived/actions/workflows/ci_ruby.yml)

## Why?

The original version of this gem seemed to have been unmaintained at least since 2018.

This fork aims to bring support for Ruby 3.0, 3.1 and 3.2. It should be a drop-in replacement.

## Original docs

TCR is a *very* lightweight version of [VCR](https://github.com/vcr/vcr) for TCP sockets.

Currently used for recording 'net/smtp', 'net/imap' and 'net/ldap' interactions so only a few of the TCPSocket methods are recorded out.

## Installation

Add this line to your application's Gemfile:

    gem 'tcr_revived', require: 'tcr'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tcr_revived

## Usage

```ruby
require 'test/unit'
require 'tcr'

TCR.configure do |c|
  c.cassette_library_dir = 'fixtures/tcr_cassettes'
  c.hook_tcp_ports = [2525]
end

class TCRTest < Test::Unit::TestCase
  def test_example_dot_com
    TCR.use_cassette('mandrill_smtp') do
      tcp_socket = TCPSocket.open("smtp.mandrillapp.com", 2525)
      io = Net::InternetMessageIO.new(tcp_socket)
      assert_match /220 smtp.mandrillapp.com ESMTP/, io.readline
    end
  end
end
```

Run this test once, and TCR will record the tcp interactions to fixtures/tcr_cassettes/google_smtp.json.

```json
[
  [
    [
      "read",
      "220 smtp.mandrillapp.com ESMTP\r\n"
    ]
  ]
]
```

Run it again, and TCR will replay the interactions from json when the tcp request is made. This test is now fast (no real TCP requests are made anymore), deterministic and accurate.

You can disable TCR hooking TCPSocket ports for a given block via `turned_off`:

```ruby
TCR.turned_off do
  tcp_socket = TCPSocket.open("smtp.mandrillapp.com", 2525)
end
```

To make sure all external calls really happened use `hit_all` option:

```ruby
class TCRTest < Test::Unit::TestCase
  def test_example_dot_com
    TCR.use_cassette('mandrill_smtp', hit_all: true) do
      # There are previously recorded external calls.
      # ExtraSessionsError will be raised as a result.
    end
  end
end
```

You can also use the configuration option:

```ruby
TCR.configure do |c|
  c.hit_all = true
end
```

The following storage formats are supported:

- JSON (default)
- YAML
- Marshal (recommended for binary data transfer like LDAP)

You can configure them via:

```ruby
TCR.configure do |c|
  c.format = 'json'
  # or
  c.format = 'yaml'
  # or
  c.format = 'marshal'
end
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
