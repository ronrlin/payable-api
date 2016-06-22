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

If you want to build the gem from source:

$ gem build payable.gemspec
Alternatively, you can install the gem from Rubyforge:

$ gem install payable

# Usage

require "payable"

Payable.api_key = '<your_api_key_here>'
client = Payable::Client.new()

# send a transaction event -- note this is blocking
event = "$transaction"

user_id = "23056" # User ID's may only contain a-z, A-Z, 0-9, =, ., -, _, +, @, :, &, ^, %, !, $

properties = {
 "$user_id" => user_id,
  "$user_email" => "buyer@gmail.com",
  "$seller_user_id" => "2371",
  "seller_user_email" => "seller@gmail.com",
  "$transaction_id" => "573050",
  "$payment_method" => {
    "$payment_type"    => "$credit_card",
    "$payment_gateway" => "$braintree",
    "$card_bin"        => "542486",
    "$card_last4"      => "4444"
  },
  "$currency_code" => "USD",
  "$amount" => 15230000,
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
