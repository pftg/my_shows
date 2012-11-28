require 'logger'

module MyShows
  def self.logger
    @logger ||= ::Logger.new(STDOUT)
  end
end