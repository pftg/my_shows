require 'my_shows/version'

require "bundler/setup"

require 'netrc'
require 'fuzzystringmatch'

require 'my_shows/logger'
require 'my_shows/auth'
require 'my_shows/sidereel_client'
require 'my_shows/show'
require 'my_shows/the_pirate_bay_client'

module MyShows
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
        jarow = FuzzyStringMatch::JaroWinkler.create(:native)

        next_episodes.map do |episode|
          episode_search_query = "%s s%02de%02d PublicHD" % [episode.name, episode.season, episode.episode]
          logger.info "Looking for '#{episode_search_query}' ..."

          begin
            torrents = tracker.search(episode_search_query)
            torrent = torrents.sort_by do |torrent|
              jarow.getDistance(episode_search_query, torrent.name)
            end.reverse.first

            [torrent.magnet_link, episode] if torrent
          rescue => e
            logger.warn "Problem with looking torrent link"
            logger.debug e.message
            nil
          end
        end.compact
      end

      def enque_to_download links
        links.each do |link|
          logger.debug "Enque #{link.last.name} #{link.first}"
          `open '#{link.first}'`
          logger.debug 'Sleep in 10 sec'
          sleep 10
        end
      end

      def start *args
        configure_client
        enque_to_download links_for(Show.next_episodes)
      end
    end
  end
end

if __FILE__ == $0
  MyShows.logger.level = ::Logger::FATAL
  MyShows::CLI.start
end
