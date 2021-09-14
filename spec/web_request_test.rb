require 'uri'
require 'net/http'

require 'thoreau/auto_run'
include Thoreau::DSL

test_suite 'http request' do

  test_cases 'response code' do

    subject { Net::HTTP.get_response(uri).code }

    spec setups: 'working URIs',
         equal:  '200'
    spec setups: 'redirecting URI',
         equal:  '301'
    spec setups: 'non-existent URI',
         raises: SocketError
  end

  test_cases 'body' do

    action { Net::HTTP.get_response(uri).body }

    spec 'AmpWhat contains my name',
         setup:   'amp-what home',
         asserts: proc { |body| body.to_s =~ /Andrew J. Peterson/ }
    spec 'AmpWhat contains NDP Software',
         setup:   'amp-what home',
         asserts: proc { |body| body.to_s =~ /NDP Software/ }
    spec 'AmpWhat expected content',
         setup:  ['amp-what expected content', 'amp-what home'],
         assert: proc { |body| body.to_s =~ /#{expected_content}/ }
  end

  test_cases 'HEAD request' do

    action do
      response = nil
      http     = Net::HTTP.new('www.amp-what.com', 80)
      http.start { |http|
        response = http.head('/')
      }
      response['content-type']
    end

    spec 'returns content type',
         equals: 'text/html'
  end

  appendix do
    setup 'working URIs',
          { uri: expanded([
                            'https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY',
                            'https://www.google.com/',
                            'https://www.amp-what.com',
                          ].map { |uri| URI(uri) }) }
    setup 'redirecting URI', { uri: URI('https://google.com') }
    setup 'non-existent URI', { uri: URI('http://example-asdjfkladjsflkasflas.com') }
    setup 'amp-what home', { uri: URI('https://www.amp-what.com/') }
    setup 'amp-what expected content', { expected_content: expanded(['Andrew J. peterson', 'NDP Software']) }
    setup 'amp-what search result', { uri: URI('https://www.amp-what.com/unicode/search/x') }
    setup 'google search result', { uri: 'https://google.com/q=panda' }
  end
end
