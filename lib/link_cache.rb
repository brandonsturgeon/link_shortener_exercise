# frozen_string_literal: true

# Maps fully qualified URL's to their shortened paths
module LinkCache
  # Intentionally making this a class variable to more easily use this module's methods across files and scopes.
  # While this is an antipattern, it's worth noting that this entire storage solution is, in itself, an antipattern.
  # Instead, one could implement a persisent storage tool (flat-file or otherwise), and refactor this module into a relatively simple interface with the storage tool.
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
