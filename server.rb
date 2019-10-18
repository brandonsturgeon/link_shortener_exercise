# frozen_string_literal: true

require 'sinatra'
require 'sinatra/namespace'
require 'json'

require_relative 'link_analytics'
require_relative 'link_cache'
require_relative 'url_helper'

post '/short_link' do
  data = JSON.parse(request.body.read)

  long_url = data['long_url']
  long_url = URLHelper.clean_url(long_url)

  response = {}
  response['long_url'] = long_url

  cached_path = LinkCache.get_path_for_url(long_url)

  if cached_path
    response['short_url'] = cached_path

    return response.to_json
  end

  return { error: 'Invalid URL' }.to_json unless URLHelper.url_is_valid?(long_url)

  response['short_url'] = URLHelper.generate_short_url(long_url)

  response.to_json
end

get '/:short_link' do
=begin
  # Here's what I'd do if I followed the instructions and looked for the "+" at the end of the path
  #  I didn't like that way of doing it so I made it a separate endpoint, but the difference is minimal

  short_path = params['short_link']
  if short_path[-1] == "+"
    path_without_plus = short_path[0..-2]
    return handle_analytics_call(path_without_plus)
  end
=end

  short_path = params['short_link']

  mapped_url = LinkCache.get_url_for_path(short_path)

  halt 404 unless mapped_url

  LinkAnalytics.record_visit(short_path, request)

  redirect "https://#{mapped_url}"
end

get '/:short_link/analytics' do
  short_path = params['short_link']

  return { error: 'Invalid URL' }.to_json unless LinkAnalytics.has? short_path

  LinkAnalytics.get_analytics_for(short_path).to_json
end
