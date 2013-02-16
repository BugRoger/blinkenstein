source 'https://rubygems.org'

gemspec

%w[blink1-patterns].each do |lib|
  library_path = File.expand_path("../../#{lib}", __FILE__)
  if File.exist?(library_path)
    gem lib, :path => library_path
  else
    gem lib, :git => "git://github.com/bugroger/#{lib}.git"
  end
end
