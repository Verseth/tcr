# frozen_string_literal: true

require 'tcr/cassette'
require 'tcr/configuration'
require 'tcr/errors'
require 'tcr/recordable_tcp_socket'
require 'tcr/version'
require 'socket'
require 'json'


module TCR
  extend self

  def configure
    yield configuration
  end

  def configuration
    @configuration ||= Configuration.new
  end

  def cassette
    @cassette
  end

  def cassette=(val)
    @cassette = val
  end

  def disabled
    @disabled || false
  end

  def disabled=(val)
    @disabled = val
  end

  def save_session; end

  def use_cassette(name, options = {}, &block)
    raise ArgumentError, '`TCR.use_cassette` requires a block.' unless block

    TCR.cassette = Cassette.new(name)
    yield
    TCR.cassette.save
    TCR.cassette.check_hits_all_sessions if options[:hit_all] || configuration.hit_all
  ensure
    TCR.cassette = nil
  end

  def turned_off(&block)
    raise ArgumentError, '`TCR.turned_off` requires a block.' unless block

    current_hook_tcp_ports = configuration.hook_tcp_ports
    configuration.hook_tcp_ports = []
    yield
    configuration.hook_tcp_ports = current_hook_tcp_ports
  end
end

# The monkey patch shim
class TCPSocket
  class << self
    alias_method :real_open,  :open

    def open(address, port, *_args)
      if TCR.configuration.hook_tcp_ports.include?(port)
        TCR::RecordableTCPSocket.new(address, port, TCR.cassette)
      else
        real_open(address, port)
      end
    end
  end
end

class OpenSSL::SSL::SSLSocket # rubocop:disable Style/StaticClass
  class << self
    def new(io, *args)
      if io.is_a?(TCR::RecordableTCPSocket)
        TCR::RecordableSSLSocket.new(io)
      else
        super
      end
    end
  end
end

class Socket
  class << self
    alias_method :real_tcp, :tcp

    def tcp(host, port, *socket_opts)
      if TCR.configuration.hook_tcp_ports.include?(port)
        TCR::RecordableTCPSocket.new(host, port, TCR.cassette)
      else
        real_tcp(host, port, *socket_opts)
      end
    end
  end
end
