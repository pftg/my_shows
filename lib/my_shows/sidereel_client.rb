require 'faraday_middleware'

class SidereelClient < Struct.new(:username, :password)
  def connection
    MyShows.logger.info "Create connection for #{username}"
    @connection ||= Faraday.new url: 'http://www.sidereel.com' do |conn|
      conn.request :url_encoded # form-encode POST params
      conn.request :basic_auth, username, password
      conn.request :json

      conn.response :mashify
      conn.response :json

      conn.response :logger

      conn.adapter Faraday.default_adapter
    end
  end

  def tracked_tv_shows
    response = connection.get '/users/tracked_tv_shows'
    @shows ||= response.body
  end
end
