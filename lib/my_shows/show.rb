module MyShows
  class Show
    def self.client
      @client ||= SidereelClient.new
    end

    def self.next_episodes
      tv_shows = client.tracked_tv_shows.first[1].
        map(&:tv_show).reject { |show|
        show.next_episode.nil? || show.next_episode.is_upcoming #|| (Date.parse(show.next_episode.air_date_utc) >= Time.now.to_date)
        #TODO: Maybe better just get `is_upcoming == false` attribute
      }.map do |show|
        Hashie::Mash.new.tap { |result|
          result.name    = show.complete_name
          result.season  = show.next_episode.season_number
          result.episode = show.next_episode.season_ordinal
        }
      end
    end
  end
end
