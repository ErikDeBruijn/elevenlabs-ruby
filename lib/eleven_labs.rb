module ElevenLabs
  class Error < StandardError; end

  class << self
    attr_writer :api_key

    def api_key
      @api_key || ENV.fetch("ELEVENLABS_API_KEY", nil)
    end

    def configure
      yield self
    end

    def client
      @client ||= Client.new
    end

    def reset_client!
      @client = nil
    end

    def text_to_speech(...) = client.text_to_speech(...)
    def voices(...) = client.voices(...)
  end
end

require_relative "eleven_labs/version"
require_relative "eleven_labs/client"
