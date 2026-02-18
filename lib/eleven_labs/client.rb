require "faraday"
require "json"

module ElevenLabs
  class Client
    BASE_URL = "https://api.elevenlabs.io"

    def initialize(api_key: nil)
      @api_key = api_key || ElevenLabs.api_key
    end

    def text_to_speech(text:, voice_id:, model_id: "eleven_multilingual_v2", output_format: "mp3_44100_128")
      response = connection.post("/v1/text-to-speech/#{voice_id}") do |req|
        req.params[:output_format] = output_format
        req.headers["Content-Type"] = "application/json"
        req.body = { text: text, model_id: model_id }.to_json
      end

      raise Error, error_message(response) unless response.success?

      { data: response.body, filename: "speech.mp3", content_type: "audio/mpeg" }
    end

    def voices(search: nil)
      params = {}
      params[:search] = search if search

      response = connection.get("/v2/voices", params)

      raise Error, error_message(response) unless response.success?

      parsed = JSON.parse(response.body)
      parsed["voices"].map do |v|
        { voice_id: v["voice_id"], name: v["name"], category: v["category"] }
      end
    end

    private

    def connection
      @connection ||= Faraday.new(url: BASE_URL) do |f|
        f.headers["xi-api-key"] = @api_key
        f.options.timeout = 60
        f.options.open_timeout = 10
      end
    end

    def error_message(response)
      parsed = JSON.parse(response.body)
      detail = parsed["detail"]
      return detail["message"] if detail.is_a?(Hash)
      return detail if detail.is_a?(String)

      "Request failed (#{response.status})"
    rescue JSON::ParserError
      "Request failed (#{response.status})"
    end
  end
end
