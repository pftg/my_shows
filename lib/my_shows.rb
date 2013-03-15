#!ruby19
# encoding: utf-8

require 'my_shows/version'

require "bundler/setup"

require 'netrc'
require 'fuzzystringmatch'
require 'colorize'

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

      def lookup_magnet_links shows
        shows.map { |show|
          show.episode.torrent_link!
        }.compact
      end

      def enque_to_download links
        links.each do |link|
          logger.debug "Enque #{link}"
          sleep 5
          Launchy::Application::General.new.open(["#{URI(link).to_s}"])
        end
      end

      def start *args
        print_header
        configure_client
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
        puts "Next episodes:"
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
  MyShows.logger.level = ::Logger::FATAL
  MyShows::CLI.start
end
