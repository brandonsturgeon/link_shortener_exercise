# frozen_string_literal: true

# Maps fully qualified URL's to their shortened paths
module LinkCache
  # intentionally making this a class var to aid legibility in server.rb
  # (while it is an antipattern, this wouldn't be the right scale-able solution anyway.)
  @@cache = {}

  def self.map(long_url, short_path)
    @@cache[long_url] = short_path
  end

  def self.get_path_for_url(long_url)
    @@cache[long_url]
  end

  def self.get_url_for_path(short_path)
    @@cache.key(short_path)
  end
end
