module Sqwiggle
  class API
    def conn
      @conn ||= Faraday.new(:url => base_api_uri) do |faraday|
        faraday.response :logger, logger          # log requests to STDOUT
        faraday.response :raise_http_exception    # handle errors
        #faraday.response :ascii8bit
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
        faraday.basic_auth(creds[:api_key], creds[:api_secret])
      end
    end

    def get_new_api_key(rloc_usr, rloc_pwd)
      #POST to the login method
    end

    def end_point
      @end_point = CONFIG['sqwiggle_api_endpoint']
    end

    def base_api_uri
      @base_uri ||= "https://#{CONFIG['sqwiggle_api_endpoint']}"
    end

    def credentials_path
      "#{File.expand_path('../../../', __FILE__)}/.api_creds"
    end

    def creds
      @creds ||= YAML.load(File.read(credentials_path))[end_point]
    end

    def response(end_point, format='json')
      @response = conn.get "#{end_point}" do |request|
        request.options[:timeout] = 900
        request.options[:open_timeout] = 900
      end
      @body = JSON.parse(@response.body)
    end
  end
end
