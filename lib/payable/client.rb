require 'httparty'
require 'multi_json'

module Payable
  # Represents the payload returned from a call through the track API
  #
  class Response
    attr_reader :body
    attr_reader :http_class
    attr_reader :http_status_code
    attr_reader :api_status
    attr_reader :api_error_message
    attr_reader :request

    # Constructor
    #
    # == Parameters:
    # http_response
    #   The HTTP body text returned from the API call. The body is expected to be
    #   a JSON object that can be decoded into status, message and request
    #   sections.
    #
    def initialize(http_response, http_response_code, http_raw_response)
      @http_status_code = http_response_code
      @http_raw_response = http_raw_response

      # only set these variables if a message-body is expected.
      if not @http_raw_response.kind_of? Net::HTTPNoContent
        @body = MultiJson.load(http_response) unless http_response.nil?
        @request = MultiJson.load(@body["request"].to_s) if @body["request"]
        @api_status = @body["status"].to_i if @body["status"]
        @api_error_message = @body["error_message"].to_s if @body["error_message"]
      end
    end

    # Helper method returns true if and only if the response from the API call was
    # successful
    #
    # == Returns:
    #   true on success; false otherwise
    def ok?

      if @http_raw_response.kind_of? Net::HTTPNoContent
        #if there is no content expected, use HTTP code
        204 == @http_status_code
      else
        # otherwise use API status
        @http_raw_response.kind_of? Net::HTTPOK and 0 == @api_status.to_i
      end
    end

  end

  # This class wraps accesses through the API
  # curl -u company_id:api_key https://api.payable.com/v1/
  class Client
    API_ENDPOINT = "https://api.payable.com"
    API_TIMEOUT = 2

    include HTTParty
    base_uri API_ENDPOINT

    # Constructor
    #
    # == Parameters:
    # api_key
    #   The Payable API key associated with your customer account. This parameter
    #   cannot be nil or blank.
    # path
    #   The path to the Payable API, e.g., "/v1/workers"
    # company_id
    #   The company id associated with the Payable account.
    #
    def initialize(api_key = Payable.api_key, path = Payable.current_rest_api_path, timeout = API_TIMEOUT, company_id = Payable.company_id)
      raise("api_key must be a non-empty string") if !api_key.is_a?(String) || api_key.empty?
      raise("path must be a non-empty string") if !path.is_a?(String) || path.empty?
      @api_key = api_key
      @path = path
      @timeout = timeout
      @company_id = company_id
    end

    def api_key
      @api_key
    end

    def company_id
      @company_id
    end

    #def user_agent
    #  "Payable/v#{API_VERSION} payable-ruby/#{VERSION}"
    #end

    # Creates a new worker.
    #
    # == Parameters:
    # properties
    #   A hash of name-value pairs that specifies information about the worker .
    #
    #   display_name : String - The full name of the individual or business
    #   first_name optional : String - The first name if this is an individual
    #   last_name optional : String - The last name if this is an individual
    #   email optional : String - The email address for this Worker.
    #   invite optional : Boolean - Indicates if the Worker should be invited to your company. Default: true.
    #
    # == Returns:
    #   In the case of an HTTP error (timeout, broken connection, etc.), this
    #   method returns nil; otherwise, a Response object is returned and captures
    #   the status message and status code.
    #
    def create_worker(properties = {}, api_key = @api_key)
      warn "[WARNING] api_key cannot be empty, fallback to default api_key." if api_key.to_s.empty?
      api_key ||= @api_key
      raise("properties cannot be empty") if properties.empty?
      raise("Bad api_key parameter") if api_key.empty?
      path ||= @path
      timeout ||= @timeout

      begin
        auth = {:username => "#{company_id}", :password => "#{api_key}"}
        response = self.class.post("/v#{API_VERSION}/workers",
                        {
                          :query => properties,
                          :basic_auth => auth
                        }
                      )

        Response.new(response.body, response.code, response.response)
      rescue StandardError => e
        Payable.warn("Failed to track event: " + e.to_s)
        Payable.warn(e.backtrace)
        nil
      end
    end

    # Retrieves a worker's account.
    #
    # == Parameters:
    # worker_id
    #   A worker's id.
    #
    # == Returns:
    #   A Response object is returned.
    #
    def worker(worker_id, api_key = @api_key)
      raise("worker_id must be a non-empty string") if (!worker_id.is_a? String) || worker_id.to_s.empty?
      raise("Bad api_key parameter") if api_key.empty?
      timetout ||= @timeout

      auth = {:username => "#{company_id}", :password => "#{api_key}"}
      response = self.class.get("/v#{API_VERSION}/workers/#{worker_id}",
                     :basic_auth => auth)

      Response.new(response.body, response.code, response.response)
    end

    # Creates a record of work done.
    #
    # == Parameters:
    #
    # worker_id : String - Reference to a Worker that performed this work.
    #
    # work_type_id : Number - Identifies a Work Type configured in your Payable app
    #
    # quantity : Number - The quantity of work performed. The referenced Work Type's quantity_measure determines the unit of measure and precision. * hourly -> Integer # of seconds * money -> Integer # of cents * unit -> Float # of units * distance-> Float # of miles
    #
    # start : String - ISO 8601 - The date information is required, and hours, minutes, and seconds fields are encouraged
    #
    # end : (optional) String - ISO 8601 - Only relevant if you have hours, minutes, and seconds data for the “start” field
    #
    # notes : (optional) String - Description of the work
    #
    # == Returns:
    #   In the case of an HTTP error (timeout, broken connection, etc.), this
    #   method returns nil; otherwise, a Response object is returned and captures
    #   the status message and status code.
    #
    def create_work(worker_id, work_type_id, quantity, start_date, end_date, notes, api_key = @api_key)
      warn "[WARNING] api_key cannot be empty, fallback to default api_key." if api_key.to_s.empty?
      api_key ||= @api_key
      raise("worker_id is required") if worker_id.empty?
      raise("work_type_id is required") if work_type_id.empty?
      raise("quantity is required") if quantity.empty?
      raise("start_date is required") if start_date.empty?
      raise("Bad api_key parameter") if api_key.empty?
      path ||= @path
      timeout ||= @timeout

      begin
        auth = {:username => "#{company_id}", :password => "#{api_key}"}

        parameters = {
          "worker_id" => worker_id,
          "work_type_id" => work_type_id,
          "quantity" => quantity,
          "start_date" => start_date,
          "end_date" => end_date,
          "notes" => notes,
        }

        response = self.class.post("/v#{API_VERSION}/workers",
                        {
                          :query => parameters,
                          :basic_auth => auth
                        }
                      )

        Response.new(response.body, response.code, response.response)
      rescue StandardError => e
        Payable.warn("Failed to track event: " + e.to_s)
        Payable.warn(e.backtrace)
        nil
      end
    end

  end
end
