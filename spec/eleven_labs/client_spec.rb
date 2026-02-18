require "eleven_labs"
require "webmock/rspec"

RSpec.describe ElevenLabs::Client do
  subject(:client) { described_class.new(api_key: "test-key") }

  describe "#text_to_speech" do
    let(:voice_id) { "21m00Tcm4TlvDq8ikWAM" }
    let(:audio_data) { "\xFF\xFB\x90\x00" } # fake MP3 bytes

    before do
      stub_request(:post, "https://api.elevenlabs.io/v1/text-to-speech/#{voice_id}")
        .with(
          query: { output_format: "mp3_44100_128" },
          headers: { "xi-api-key" => "test-key", "Content-Type" => "application/json" },
          body: { text: "Hello world", model_id: "eleven_multilingual_v2" }.to_json
        )
        .to_return(status: 200, body: audio_data)
    end

    it "returns audio data with metadata" do
      result = client.text_to_speech(text: "Hello world", voice_id: voice_id)

      expect(result[:data]).to eq(audio_data)
      expect(result[:filename]).to eq("speech.mp3")
      expect(result[:content_type]).to eq("audio/mpeg")
    end

    it "sends the output_format as a query parameter" do
      stub_request(:post, "https://api.elevenlabs.io/v1/text-to-speech/#{voice_id}")
        .with(query: { output_format: "pcm_44100" })
        .to_return(status: 200, body: audio_data)

      client.text_to_speech(text: "Hello world", voice_id: voice_id, output_format: "pcm_44100")

      expect(WebMock).to have_requested(:post, "https://api.elevenlabs.io/v1/text-to-speech/#{voice_id}")
        .with(query: { output_format: "pcm_44100" })
    end

    it "raises Error on API failure" do
      stub_request(:post, "https://api.elevenlabs.io/v1/text-to-speech/#{voice_id}")
        .with(query: hash_including(output_format: "mp3_44100_128"))
        .to_return(status: 401, body: { detail: { message: "Invalid API key" } }.to_json)

      expect { client.text_to_speech(text: "Hello", voice_id: voice_id) }
        .to raise_error(ElevenLabs::Error, "Invalid API key")
    end
  end

  describe "#voices" do
    let(:voices_response) do
      {
        voices: [
          { voice_id: "abc123", name: "Rachel", category: "premade" },
          { voice_id: "def456", name: "Domi", category: "premade" }
        ]
      }.to_json
    end

    before do
      stub_request(:get, "https://api.elevenlabs.io/v2/voices")
        .with(headers: { "xi-api-key" => "test-key" })
        .to_return(status: 200, body: voices_response)
    end

    it "returns a list of voices" do
      result = client.voices

      expect(result.size).to eq(2)
      expect(result.first).to eq(voice_id: "abc123", name: "Rachel", category: "premade")
    end

    it "passes search parameter" do
      stub_request(:get, "https://api.elevenlabs.io/v2/voices")
        .with(query: { search: "Dutch" })
        .to_return(status: 200, body: { voices: [] }.to_json)

      result = client.voices(search: "Dutch")

      expect(result).to eq([])
    end

    it "raises Error on API failure" do
      stub_request(:get, "https://api.elevenlabs.io/v2/voices")
        .to_return(status: 500, body: { detail: "Internal error" }.to_json)

      expect { client.voices }.to raise_error(ElevenLabs::Error, "Internal error")
    end
  end
end

RSpec.describe ElevenLabs do
  after { described_class.reset_client! }

  describe ".configure" do
    it "sets the api_key" do
      described_class.configure { |c| c.api_key = "my-key" }

      expect(described_class.api_key).to eq("my-key")
    end
  end

  describe ".api_key" do
    it "falls back to ENV" do
      described_class.api_key = nil
      allow(ENV).to receive(:fetch).with("ELEVENLABS_API_KEY", nil).and_return("env-key")

      expect(described_class.api_key).to eq("env-key")
    end
  end

  describe "delegation" do
    it "delegates text_to_speech to client" do
      client = instance_double(ElevenLabs::Client)
      allow(described_class).to receive(:client).and_return(client)
      allow(client).to receive(:text_to_speech).and_return({ data: "audio" })

      result = described_class.text_to_speech(text: "hi", voice_id: "abc")

      expect(client).to have_received(:text_to_speech).with(text: "hi", voice_id: "abc")
      expect(result).to eq({ data: "audio" })
    end

    it "delegates voices to client" do
      client = instance_double(ElevenLabs::Client)
      allow(described_class).to receive(:client).and_return(client)
      allow(client).to receive(:voices).and_return([])

      described_class.voices(search: "Dutch")

      expect(client).to have_received(:voices).with(search: "Dutch")
    end
  end
end
