source 'https://rubygems.org'

gemspec

%w[blink1-patterns].each do |lib|
  library_path = File.expand_path("../../#{lib}", __FILE__)
  if File.exist?(library_path)
    gem lib, :path => library_path
  else
    gem lib, :git => "git://github.com/BugRoger/#{lib}.git"
  end
end


group :development do
  gem 'guard'
  gem 'guard-rspec'
  gem 'rake'
  gem 'rb-fsevent', :require => false
end

group :test do
  gem 'vcr'
  gem 'webmock'
  gem 'rspec'
end
