require 'rack/acceptable'

module Rack
  class Conneg
    VERSION = '0.1.0'.freeze
  end
end

require 'rack/conneg/file'
require 'rack/conneg/negotiator'
require 'rack/conneg/path'
require 'rack/conneg/static'
