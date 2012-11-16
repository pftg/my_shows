module MyShows
  class Show
    def self.client client = nil
      @client ||= SidereelClient.new ENV["SIDEREEL_USERNAME"], ENV["SIDEREEL_PASSWORD"]
    end

    def self.client= client
      @client = client
    end

    def self.next_episodes
      client.tracked_tv_shows.first[1].map(&:tv_show).reject do |show|
        show.next_episode.nil? || show.next_episode.is_upcoming #|| (Date.parse(show.next_episode.air_date_utc) >= Time.now.to_date)
      end.map do |show|
        Hashie::Mash.new name: show.complete_name,
          season:  show.next_episode.season_number,
          episode: show.next_episode.season_ordinal
      end
    end
  end
end
