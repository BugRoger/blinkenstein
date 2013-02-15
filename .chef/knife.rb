log_level     :info
log_location  STDOUT
cache_type    "BasicFile"
cache_options(path: File.expand_path("../checksums", __FILE__))
cookbook_path [ File.expand_path("../../chef/cookbooks", __FILE__) ]
solo_path    "chef"
