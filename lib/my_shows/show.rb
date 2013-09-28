require 'hashie'
require 'hashie/mash'

module MyShows
  class Show < Hashie::Mash
    def self.client
      @client ||= SidereelClient.new ENV['SIDEREEL_USERNAME'], ENV['SIDEREEL_PASSWORD']
    end

    def self.client= client
      @client = client
    end

    def initialize(*attrs)
      super
      attrs.last[:episode].show = self if attrs.last && attrs.last[:episode]
    end

    def self.next_episodes
      client.tracked_tv_shows.first[1].map(&:tv_show).reject do |show_data|
        MyShows.logger.debug "TV Show data: #{show_data.inspect}"
        next_episode = show_data.next_episode
        next_episode.nil? || next_episode.is_upcoming
      end.map do |show_data|
        next_episode_data = show_data.next_episode

        episode = MyShows::Episode.new(season: next_episode_data.season_number,
          episode: next_episode_data.season_ordinal)

        Show.new name: show_data.complete_name, episode: episode
      end
    end
  end
end
