require 'my_shows/version'

require "rubygems"
require 'logger'
require "bundler/setup"

require 'netrc'
require 'fuzzystringmatch'

$: << File.expand_path(File.join(File.dirname(__FILE__), 'my_shows'))
require 'auth'
require 'sidereel_client'
require 'show'
require 'the_pirate_bay_client'

module MyShows
  def self.logger
    @logger ||= ::Logger.new(STDOUT)
  end

  class CLI
    class <<self
      include MyShows::Auth

      def logger
        MyShows.logger
      end

      def configure_client
        MyShows::Show.client = SidereelClient.new(*self.credentials)
      end

      def links_for next_episodes
        tracker = ThePirateBayClient.new
        jarow   = FuzzyStringMatch::JaroWinkler.create(:native)

        next_episodes.map do |episode|
          episode_search_query = "%s s%02de%02d PublicHD" % [episode.name, episode.season, episode.episode]
          logger.info "Looking for '#{episode_search_query}' ..."

          begin
            torrents = tracker.search(episode_search_query)
            torrent = torrents.sort_by { |torrent| 
              jarow.getDistance(episode_search_query, torrent.name)
            }.reverse.first

            torrent.try :magnet_link
          rescue => e
            logger.warn "Problem with looking torrent link"
            logger.debug e.message
          end
        end.compact
      end

      def enque_to_download links
        links.each do |link|
          logger.debug "Enque #{link}"
          `open '#{link}'`
          logger.debug 'Sleep in 10 sec'
          sleep 10
        end
      end

      def start *args
        configure_client
        enque_to_download links_for Show.next_episodes
      end
    end
  end
end

if __FILE__ == $0
  MyShows::CLI.start
end
