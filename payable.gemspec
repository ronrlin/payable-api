Gem::Specification.new do |s|
  s.name        = 'payable'
  s.version     = '0.0.0'
  s.date        = '2016-06-22'
  s.summary     = "Payable API"
  s.description = "Integrate the Payable API"
  s.authors     = ["Ron Lin"]
  s.email       = 'ronrlin@gmail.com'
  s.files       = ["lib/payable.rb"]
  s.homepage    = 'http://rubygems.org/gems/payable'
  s.license     = 'MIT'
  s.add_dependency "httparty", ">= 0.11.0"
  s.add_dependency "multi_json", ">= 1.0"
end
