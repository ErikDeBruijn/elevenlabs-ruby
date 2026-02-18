# elevenlabs-ruby

Thin Ruby client for the [ElevenLabs](https://elevenlabs.io) text-to-speech API. Built for use in [chatapp](https://github.com/erikdebruijn/chatapp) as an `RubyLLM::Tool` backend — same pattern as `comfyui-ruby`.

## Usage

```ruby
ElevenLabs.configure do |c|
  c.api_key = ENV["ELEVENLABS_API_KEY"]
end

# Text to speech
result = ElevenLabs.text_to_speech(text: "Hallo wereld", voice_id: "21m00Tcm4TlvDq8ikWAM")
# => { data: <binary MP3>, filename: "speech.mp3", content_type: "audio/mpeg" }

# List voices
ElevenLabs.voices(search: "Dutch")
# => [{ voice_id: "...", name: "...", category: "..." }, ...]
```

## Installation

In your Gemfile:

```ruby
gem "eleven_labs", path: "path/to/elevenlabs-ruby"
```

## Running specs

```
bundle exec rspec
```
