%w(libusb-1.0-0-dev libxslt-dev libxml2-dev).each do |name|
  package name
end

%w(bundler blinkenstein).each |name|
  gem_package name
end
