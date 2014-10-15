module Lita
  # A wrapper around a handler's HTTP route callbacks that sets up the request and response.
  # @api private
  # @since 4.0.0
  class HTTPCallback
    def initialize(handler_class, callback)
      @handler_class = handler_class
      @callback = callback
    end

    # Call the Rack endpoint with a standard environment hash.
    def call(env)
      request = Rack::Request.new(env)
      response = Rack::Response.new

      if request.head?
        response.status = 204
      else
        handler = @handler_class.new(env["lita.robot"])

        @callback.call(handler, request, response)
      end

      response.finish
    end
  end
end
