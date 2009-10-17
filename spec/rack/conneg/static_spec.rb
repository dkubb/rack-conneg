require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

shared_examples_for 'successful' do
  it 'should return 200' do
    last_response.status.should == 200
  end
end

shared_examples_for 'not found' do
  it 'should return 404' do
    last_response.status.should == 404
  end
end

shared_examples_for 'not acceptable' do
  before do
    @content = "406 Not Acceptable\n"
  end

  it_should_behave_like 'negotiated'
  it_should_behave_like 'content expected'
  it_should_behave_like 'not variant'

  it 'should return 406' do
    last_response.status.should == 406
  end
end

shared_examples_for 'not negotiated' do
  it_should_behave_like 'not variant'

  it 'should not set Vary' do
    last_response.headers.should_not include('Vary')
  end
end

shared_examples_for 'negotiated' do
  it 'should set Vary' do
    last_response.headers['Vary'].should == 'Accept'
  end
end

shared_examples_for 'not variant' do
  it 'should not set Content-Location' do
    last_response.headers.should_not include('Content-Location')
  end
end

shared_examples_for 'variant' do
  it 'should set Content-Location' do
    last_response.headers['Content-Location'].should == "/#{@file}"
  end
end

shared_examples_for 'content expected' do
  it 'should return expected content' do
    last_response.body.should == @content
  end
end

describe Rack::Conneg::Static do
  use_fakefs

  def app
    Rack::Conneg::Static.new(default_app, :root => @root, :urls => %w[ / ])
  end

  def default_app
    proc do
      body   = 'Default Application'
      length = Rack::Utils.bytesize(body).to_s
      [ 200, { 'Content-Type' => 'text/plain', 'Content-Length' => length }, body ]
    end
  end

  def create_file(path)
    file = Pathname(@root) + path
    file.dirname.mkpath
    file.open('w') { |io| io << path }
  end

  def create_directory(path)
    Pathname(@root).join(path).mkpath
  end

  describe 'GET known file path' do
    before do
      create_file(@file = 'index.html')

      @content = @file

      request "/#{@file}"
    end

    it_should_behave_like 'successful'
    it_should_behave_like 'not negotiated'
    it_should_behave_like 'content expected'
  end

  describe 'GET unknown file path' do
    before do
      request '/unknown'
    end

    it_should_behave_like 'not found'
    it_should_behave_like 'not negotiated'
  end

  describe 'GET path that is not a file' do
    before do
      create_directory(@directory = 'test.txt')

      request "/#{@directory}"
    end

    it_should_behave_like 'not found'
    it_should_behave_like 'not negotiated'
  end

  describe 'GET path with no directory' do
    before do
      request '/test/index'
    end

    it_should_behave_like 'not found'
    it_should_behave_like 'not negotiated'
  end

  describe 'GET path for file with unknown media type' do
    before do
      pending

      create_file(@file = 'index.unknown')

      request "/#{@file}"
    end

    it_should_behave_like 'not acceptable'
  end

  describe 'GET path that has no negotiable variants' do
    before do
      create_file('index.txt')

      request '/index', 'HTTP_ACCEPT' => 'text/html'
    end

    it_should_behave_like 'not acceptable'
  end

  describe 'GET path that has one negotiable variant' do
    before do
      create_file(@file = 'index.html')

      @content = @file

      request '/index', 'Accept' => 'text/html'
    end

    it_should_behave_like 'successful'
    it_should_behave_like 'negotiated'
    it_should_behave_like 'variant'
    it_should_behave_like 'content expected'
  end

  describe 'GET path that has many negotiable variants' do
    before do
      create_file('index.html')
      create_file('index.txt')

      @file    = 'index.html'
      @content = @file

      request '/index', 'HTTP_ACCEPT' => 'text/html;q=1,text/plain;q=0.9'
    end

    it_should_behave_like 'successful'
    it_should_behave_like 'negotiated'
    it_should_behave_like 'variant'
    it_should_behave_like 'content expected'
  end

  describe 'GET path that is not configured' do
    def app
      Rack::Conneg::Static.new(default_app, :root => @root, :urls => %w[ /other ])
    end

    before do
      create_file('index.html')

      request '/index.html'
    end

    it 'should pass through the request' do
      last_response.body.should == 'Default Application'
    end
  end

end
