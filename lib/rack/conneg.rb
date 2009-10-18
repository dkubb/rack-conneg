require 'rack/acceptable'

module Rack
  class Conneg
    VERSION = '0.1.0'.freeze

    NOT_ACCEPTABLE = [
      406,
      { 'Content-Type' => 'text/plain', 'Content-Length' => '19' },
      "406 Not Acceptable\n",
    ].freeze
  end
end

require 'rack/conneg/file'
require 'rack/conneg/negotiator'
require 'rack/conneg/path'
require 'rack/conneg/static'
require 'rack/conneg/utils'
