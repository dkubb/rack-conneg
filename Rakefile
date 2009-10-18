require 'pathname'
require 'rubygems'
require 'rake'

Pathname.glob('tasks/**/*.rake').each { |task| load task.expand_path }

begin
  require 'jeweler'

  Jeweler::Tasks.new do |gem|
    gem.name              = 'rack-conneg'
    gem.summary           = 'Rack middleware for static file content negotiation'
    gem.description       = 'Negotiate the best static file for a request based on client preferences'
    gem.email             = 'dan.kubb@gmail.com'
    gem.homepage          = 'http://github.com/dkubb/rack-conneg'
    gem.authors           = [ 'Dan Kubb' ]
    gem.rubyforge_project = 'rack-conneg'

    gem.add_dependency 'rack-acceptable'

    gem.add_development_dependency 'fakefs'
    gem.add_development_dependency 'rack-test'
    gem.add_development_dependency 'rspec'
    gem.add_development_dependency 'yard'
  end
  Jeweler::GemcutterTasks.new
  Jeweler::RubyforgeTasks.new do |rubyforge|
    rubyforge.doc_task = 'yardoc'
  end
rescue LoadError
  puts 'Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler'
end
