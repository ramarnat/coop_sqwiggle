require 'faraday'
require_relative 'error'

# @private
module FaradayMiddleware
  # @private
  class RaiseHttpException < Faraday::Response::Middleware
    def on_complete(env)
      case env[:status].to_i
      when 400
        raise Sqwiggle::BadRequest, error_message_400(env)
      when 404
        raise Sqwiggle::NotFound, error_message_400(env)
      when 500
        raise Sqwiggle::InternalServerError, error_message_500(env, "Something is technically wrong.")
      when 502
        raise Sqwiggle::BadGateway, error_message_500(env, "The server returned an invalid or incomplete response.")
      when 503
        raise Sqwiggle::ServiceUnavailable, error_message_500(env, "Sqwiggle is rate limiting your requests.")
      when 504
        raise Sqwiggle::GatewayTimeout, error_message_500(env, "504 Gateway Time-out")
      end
    end

    private

    def error_message_400(response)
      "#{response[:method].to_s.upcase} #{response[:url].to_s}: #{response[:status]}#{error_body(response[:body])}"
    end

    def error_body(body)
      # body gets passed as a string, not sure if it is passed as something else from other spots?
      if not body.nil? and not body.empty? and body.kind_of?(String)
        # removed multi_json thanks to wesnolte's commit
        body = ::JSON.parse(body)
      end

      if body.nil?
        nil
      elsif body['meta'] and body['meta']['error_message'] and not body['meta']['error_message'].empty?
        ": #{body['meta']['error_message']}"
      end
    end

    def error_message_500(response, body=nil)
      "#{response[:method].to_s.upcase} #{response[:url].to_s}: #{[response[:status].to_s + ':', body].compact.join(' ')}"
    end
  end
end

Faraday::Response.register_middleware :raise_http_exception => FaradayMiddleware::RaiseHttpException
