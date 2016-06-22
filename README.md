# payable-api

Ruby client for the Payable.com API.

# Requirements

* Ruby 1.8.7 or above. (Ruby 1.8.6 might work if you load ActiveSupport.)
* HTTParty, 0.11.0 or greater
* Multi Json, 1.0 or greater

## For development only:

* bundler
* rspec, 2.14.1 or greater
* webmock, 1.16 or greater
* rake, any version

# Installation

To build the gem from source:

$ gem build payable.gemspec

$ gem install payable

# Usage

require "payable"

Payable.api_key = '<your_api_key_here>'
client = Payable::Client.new()

# create a worker
info = {
  "display_name" => "name",
  "first_name" => "name",
  "last_name" => "lastname",
  "email" => "email@mail.com"
}

response = client.new_worker(info)

response.ok? # returns true or false

response.http_status_code # HTTP response code, 200 is ok.

response.api_status # status field in the return body, Link to Error Codes

response.api_error_message # Error message associated with status Error Code

# Log work for worker
response = client.work(id, workinfo)

response

# Building

Building and publishing the gem is captured by the following steps:

$ gem build payable.gemspec
$ gem push payable-<current version>.gem

$ bundle
$ rake -T
$ rake build
$ rake install
$ rake release
