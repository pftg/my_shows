# encoding: utf-8

require 'my_shows/version'

require 'netrc'
require 'fuzzystringmatch'
require 'colorize'
require 'pmap'

require 'my_shows/logger'
require 'my_shows/launcher'
require 'my_shows/auth'
require 'my_shows/sidereel_client'
require 'my_shows/show'
require 'my_shows/episode'

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

      def lookup_magnet_links(shows)
        shows.pmap do |show|
          link = show.episode.torrent_link!

          if link
            logger.debug "Found #{link[0...10]} for #{show.name}!"
          else
            logger.debug "Not Found any links for #{show.name}!"
          end

          link
        end.compact
      end

      def enque_to_download(links)
        links.each do |link|
          sleep 5
          uri = URI(link).to_s
          logger.info "Enque #{uri}"
          Launchy::Application::General.new.open([uri])
        end
      end

      def start(*args)
        print_header
        configure_client

        #TODO: Episode.next_unwatched.with_links.peach { |episode| print_episode episode; enquee_to_download episode; }

        shows = Show.next_episodes
        links = lookup_magnet_links(shows)
        print_episodes shows
        enque_to_download links
        print_footer
      end

      def print_header
        puts "MyShows #{MyShows::VERSION}".colorize(:light_white)
      end

      def print_episodes episodes
        puts 'Next episodes:'
        episodes.each do |show|
          episode = show.episode
          puts "#{episode} [#{episode.magnet_link ? '✓'.colorize(:green) : '✗'.colorize(:red)}]"
        end
      end

      def print_footer
        puts 'Bye!'
      end
    end
  end
end

if __FILE__ == $0
  MyShows.logger.level = ::Logger::WARN
  MyShows::CLI.start
end
