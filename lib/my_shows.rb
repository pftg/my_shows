require 'my_shows/version'

require "rubygems"
require 'logger'
require "bundler/setup"

require 'awesome_print'
require 'launchy'

require 'fuzzystringmatch'

$: << File.expand_path(File.join(File.dirname(__FILE__), 'my_shows'))
require 'sidereel_client'
require 'show'
require 'the_pirate_bay_client'

module MyShows
  log = ::Logger.new(STDOUT)

  next_episodes = Show.next_episodes
  tracker = ThePirateBayClient.new

  links = next_episodes.map do |episode|
    episode_search_query = "%s s%02de%02d PublicHD" % [episode.name, episode.season, episode.episode]
    log.info "Looking for '#{episode_search_query}' ..."

    begin
      jarow        = FuzzyStringMatch::JaroWinkler.create(:native)
      best_torrent = tracker.search(episode_search_query).sort_by { |torrent| 
        jarow.getDistance(episode_search_query, torrent.name)
      }.reverse.first

      best_torrent && best_torrent.magnet_link
    rescue => e
      log.warn "Problem with looking torrent link"
      log.debug e.message
    end
  end.compact

  links.each do |link|
    `open '#{link}'`
    log.debug 'Sleep in 10 sec'
    sleep 10
  end
end
