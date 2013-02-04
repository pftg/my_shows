require 'my_shows/the_pirate_bay_client'

module MyShows
  class Episode
    @@jarow = FuzzyStringMatch::JaroWinkler.create(:native)
    @@tracker = ThePirateBayClient.new

    attr_accessor :season, :episode, :show, :magnet_link

    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end

    def torrent_link!
      episode_search_query = "#{self.to_s} PublicHD"
      MyShows.logger.info "Looking for '#{episode_search_query}' ..."

      begin
        torrents = @@tracker.search(episode_search_query)
        torrent = torrents.sort_by { |t| @@jarow.getDistance(episode_search_query, t.name) }.reverse.first

        self.magnet_link = torrent && torrent.magnet_link
      rescue => e
        MyShows.logger.warn "Problem with looking torrent link"
        MyShows.logger.debug e.message
        nil
      end
    end

    def to_s
      "%s s%02de%02d" % [show.name, season, episode]
    end
  end
end
