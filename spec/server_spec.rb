# frozen_string_literal: true

require './spec/spec_helper'

describe 'Link Shortener App' do
  let(:disable_link_cache) { allow(LinkCache).to receive(:map).and_return(true) }

  describe 'POST /short_link' do
    context 'when given link is valid and has not been cached' do
      let(:long_url) { 'https://www.brandonsturgeon.com' }

      before(:each) do
        disable_link_cache
        post '/short_link', { 'long_url': long_url }.to_json
      end

      it 'should return 200' do
        expect(last_response.status).to eq(200)
      end

      it 'should return a shortened path' do
        body = JSON.parse(last_response.body)
        expect(body['short_url'].length).to_not eq(0)
      end

      it 'should return an appropriately cleaned long_url' do
        body = JSON.parse(last_response.body)
        expect(long_url).to include(body['long_url'])
      end
    end

    context 'when given link is invalid' do
      let(:long_url) { 'phts:/shorten.this' }

      before(:each) do
        disable_link_cache
        post '/short_link', { 'long_url': long_url }.to_json
      end

      it 'should return 400' do
        expect(last_response.status).to eq(400)
      end

      it 'should return proper error information' do
        body = JSON.parse(last_response.body)

        expect(body['error']).to eq('Invalid URL')
      end
    end
  end

  describe 'GET /:short_link' do
    context 'when given short link is valid' do
      let(:short_url) { 'test-url' }
      let(:long_url) { 'localhost:4000/test' }

      before(:each) do
        # TODO: Turn these into let's and name them something good
        allow(LinkCache).to receive(:get_url_for_path).and_return(long_url)
        allow(LinkAnalytics).to receive(:record_visit).and_return(true)

        get "/#{short_url}"
      end

      it 'should return a 302 redirect to the proper URL' do
        expect(last_response.status).to eq(302)

        expected = "https://#{long_url}"

        headers = last_response.headers
        location = headers['Location']

        expect(location).to eq(expected)
      end

      it 'should record a visit to the given link' do
        request_mock = anything

        expect(LinkAnalytics).to have_received(:record_visit).with(short_url, request_mock)
      end
    end

    context 'when given short link is invalid' do
      before(:each) do
        # TODO: Turn this into a named let, like 'force_cache_miss`
        allow(LinkCache).to receive(:get_url_for_path).and_return(false)
        allow(LinkAnalytics).to receive(:record_visit).and_return(false)

        get '/test-url'
      end

      it 'should return 404' do
        expect(last_response.status).to eq(404)
      end

      it 'should not record a visit to the given link' do
        expect(LinkAnalytics).to_not have_received(:record_visit)
      end
    end
  end

  describe 'GET /:short_link/analytics' do
    context 'when given short link is valid, and short_link has analytics' do
      let(:test_analytics) { %w[test1 test2 test3] }

      before(:each) do
        allow(LinkAnalytics).to receive(:has?).and_return(true)
        allow(LinkAnalytics).to receive(:get_analytics_for).and_return(test_analytics)

        get '/test-url/analytics'
      end

      it 'should return 200' do
        expect(last_response.status).to eq(200)
      end

      it 'should return expected data' do
        body = JSON.parse(last_response.body)

        expect(body['response']).to eq(test_analytics)
        expect(body['total_views']).to eq(test_analytics.count)
      end
    end

    context 'when given short link is valid, but short link has no analytics' do
      before(:each) do
        allow(LinkAnalytics).to receive(:has?).and_return(true)
        allow(LinkAnalytics).to receive(:get_analytics_for).and_return([])

        get '/test-url/analytics'
      end

      it 'should return 200' do
        expect(last_response.status).to eq(200)
      end

      it 'should return expected data' do
        body = JSON.parse(last_response.body)

        expect(body['response']).to eq([])
        expect(body['total_views']).to eq(0)
      end
    end

    context 'when given short link is invalid' do
      before(:each) do
        allow(LinkAnalytics).to receive(:has?).and_return(false)
        allow(URLHelper).to receive(:generate_short_url).and_return(false)

        get '/test-url/analytics'
      end

      it 'should return 200' do
        expect(last_response.status).to eq(200)
      end

      it 'should return expected error data' do
        body = JSON.parse(last_response.body)

        expect(body['error']).to eq('Invalid URL')
      end

      it 'should not generate a short url' do
        expect(URLHelper).to_not have_received(:generate_short_url)
      end
    end
  end
end
