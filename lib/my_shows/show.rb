require 'hashie'
require 'hashie/mash'

module MyShows
  class Show < Hashie::Mash
    def self.client
      @client ||= SidereelClient.new ENV["SIDEREEL_USERNAME"], ENV["SIDEREEL_PASSWORD"]
    end

    def self.client= client
      @client = client
    end

    def initialize *attrs
      super
      attrs.last[:episode].show = self if attrs.last && attrs.last[:episode]
    end

    def self.next_episodes
      client.tracked_tv_shows.first[1].map(&:tv_show).reject do |show|
        MyShows.logger.debug "TV Show data: #{show.inspect}"
        show.next_episode.nil? || show.next_episode.is_upcoming
      end.map do |show|
        episode = MyShows::Episode.new(season: show.next_episode.season_number, episode: show.next_episode.season_ordinal)
        Show.new name: show.complete_name, episode: episode
      end
    end
  end
end
