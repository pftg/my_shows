require 'faraday_middleware'
require 'nokogiri'
require 'hashie'

class ThePirateBayClient
  def connection
    @connection ||= Faraday.new url: 'http://thepiratebay.is' do |conn|
      conn.headers[:user_agent] = 'libcurl-agent/1.0'
      conn.request :url_encoded
      conn.response :logger, MyShows.logger
      conn.adapter Faraday.default_adapter
    end
  end

  def search(query)
    response = connection.get URI.escape("/search/#{query}/0/99/200")
    html     = Nokogiri::HTML(response.body)
    html.css('#searchResult > tr').map do |row|
      Hashie::Mash.new(name:        row.at_css('.detName a').content,
                       magnet_link: row.at_css('a[href^=magnet]')['href'],
                       seeders:     row.css('td')[-2].content.to_i)
    end
  end
end

if __FILE__ == $0
  require 'my_shows'
  p ThePirateBayClient.new.search('The Mentalist s05e20 PublicHD')
end
