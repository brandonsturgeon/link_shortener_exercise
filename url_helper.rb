# frozen_string_literal: true

require 'http'
require 'securerandom'

# Helpers relating to URLs
module URLHelper
  def self.generate_short_url(long_url)
    # In bytes. Length ~= bytes * 1.333..
    path_length = 4

    short_path = SecureRandom.urlsafe_base64(path_length)

    LinkCache.map(long_url, short_path)

    # TODO: make this more easily configurable, potentially automatic
    "http://localhost:8080/#{short_path}"
  end

  def self.url_is_valid?(url)
    HTTP.head("https://#{url}")
  rescue HTTP::ConnectionError, Addressable::URI::InvalidURIError
    false
  end

  def self.clean_url(long_url)
    long_url = long_url.downcase
    long_url = long_url.sub('http://', '')
    long_url = long_url.sub('https://', '')

    long_url
  end
end
