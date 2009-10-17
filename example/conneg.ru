$LOAD_PATH.unshift(::File.join(::File.dirname(__FILE__), '..', 'lib'))

require 'rack/conneg'

use Rack::Conneg::Static, :urls => [ '/example/test' ]

run proc {
  body   = 'Default'
  length = Rack::Utils.bytesize(body).to_s

  [ 200, { 'Content-Type' => 'text/plain', 'Content-Length' => length }, body ]
}
