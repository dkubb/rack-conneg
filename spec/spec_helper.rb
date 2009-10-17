$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'rack/conneg'
require 'rack/test'
require 'spec'
require 'spec/autorun'
require 'fakefs/safe'
require 'fakefs/spec_helpers'

Spec::Runner.configure do |config|
  config.include Rack::Test::Methods
  config.extend FakeFS::SpecHelpers

  config.before :all do
    @root = '/tmp'
  end
end

# fakefs does not handle the "b" open mode
module FakeFS
  class File
    def mode_in?(list)
      list.include?(@mode.sub('b', ''))
    end
  end
end

# fakefs does not wrap FileTest methods, which Pathname delegates to
class Pathname
  def exist?
    File.exist?(self)
  end
end
