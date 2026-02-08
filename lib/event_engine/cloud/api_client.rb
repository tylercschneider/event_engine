require "net/http"
require "json"
require "uri"

module EventEngine
  module Cloud
    class ApiClient
      TIMEOUT = 5

      def initialize(api_key:, endpoint:)
        @api_key = api_key
        @endpoint = endpoint
      end

      def send_batch(entries)
        post("/events", { entries: entries })
      end

      def send_heartbeat(heartbeat)
        post("/heartbeat", heartbeat)
      end

      private

      def post(path, body)
        uri = URI("#{@endpoint}#{path}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == "https"
        http.open_timeout = TIMEOUT
        http.read_timeout = TIMEOUT

        request = Net::HTTP::Post.new(uri.path)
        request["Authorization"] = "Bearer #{@api_key}"
        request["Content-Type"] = "application/json"
        request["X-EventEngine-Gem-Version"] = EventEngine::VERSION
        request.body = JSON.generate(body)

        response = http.request(request)
        response.code.start_with?("2")
      rescue StandardError => e
        EventEngine.configuration.logger.error(
          "[EventEngine::Cloud] API request failed: #{e.class} - #{e.message}"
        )
        false
      end
    end
  end
end
