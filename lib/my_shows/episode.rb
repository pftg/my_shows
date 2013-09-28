require 'my_shows/the_pirate_bay_client'

module MyShows
  class Episode
    MAPPING_SHOW_NAMES = Hash.new { |hash, key| hash[key] = key }
    MAPPING_SHOW_NAMES['Avatar: Legend of Korra'] = 'The Legend Of Korra'

    @@jarow   = FuzzyStringMatch::JaroWinkler.create(:native)
    @@tracker = ThePirateBayClient.new

    attr_accessor :season, :episode, :show, :magnet_link

    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end

    def torrent_link!
      special_authors = %w(PublicHD DIMENSION eztv \ )
      sizes           = %w(1080p 720p \ )

      special_authors.each do |author|
        sizes.each do |size|
          keyword = [author, size].join(' ')
          return self.magnet_link if torrent_link_with_ext_keyword(keyword)
        end
      end

      nil
    end

    def torrent_link_with_ext_keyword(keyword)
      episode_search_query = "#{self.to_s} #{keyword}"
      MyShows.logger.info "Looking for '#{episode_search_query}' ..."

      begin
        torrents = @@tracker.search(episode_search_query)
        torrent  = torrents.sort_by do |t|
          @@jarow.getDistance(episode_search_query, t.name)
        end.reverse.first

        self.magnet_link = torrent && torrent.magnet_link
      rescue => e
        MyShows.logger.warn "Problem with looking torrent link for '#{episode_search_query}'"
        MyShows.logger.debug e.message
        nil
      end
    end

    def to_s
      '%s s%02de%02d' % [MAPPING_SHOW_NAMES[show.name], season, episode]
    end
  end
end
