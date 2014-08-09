$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'best_choice/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'best_choice'
  s.version     = BestChoice::VERSION
  s.authors     = ['Mariusz Pruszyński']
  s.email       = ['mpruszynski@gmail.com']
  # s.homepage    = "TODO"
  s.summary     = 'TODO: Summary of BestChoice.'
  s.description = 'TODO: Description of BestChoice.'
  s.files       = Dir["{app,config,db,lib}/**/*", 
                     'MIT-LICENSE', 'Rakefile', 'README.rdoc']
  s.test_files  = Dir['test/**/*']

  s.add_runtime_dependency     'json'
  s.add_runtime_dependency     'redis-objects'
  
  s.add_development_dependency 'rr'
  s.add_development_dependency 'rails', '~> 4.0.4'
  s.add_development_dependency 'sqlite3'
end