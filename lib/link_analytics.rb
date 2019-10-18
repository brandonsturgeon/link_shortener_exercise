# frozen_string_literal: true

# Stores usage statistics for shortened URLs
module LinkAnalytics
  @@analytics = {}

  def self.record_visit(short_path, request)
    new_analytics = {}
    new_analytics[:time] = Time.now
    new_analytics[:referer] = request.referer
    new_analytics[:user_agent] = request.user_agent

    @@analytics[short_path].push(new_analytics)

    new_analytics
  end

  def self.get_analytics_for(short_path)
    @@analytics[short_path]
  end

  def self.has?(short_path)
    !@@analytics[short_path].nil?
  end

  def self.seed(short_path)
    @@analytics[short_path] ||= []
  end
end
