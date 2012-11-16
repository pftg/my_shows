module MyShows
  module Auth
    def ask
      $stdin.gets.to_s.strip
    end

    def with_tty(&block)
      return unless $stdin.isatty
      yield
    rescue
      logger.warn 'with_tty faild'
    end

    def echo_off
      with_tty do
        system "stty -echo"
      end
    end

    def echo_on
      with_tty do
        system "stty echo"
      end
    end

    def netrc
      @netrc ||= Netrc.read
    end

    def credentials
      @credentials ||= (read_credentials || ask_for_and_save_credentials)
    end

    def read_credentials
      netrc[host]
    end

    def ask_for_and_save_credentials
      begin
        @credentials = ask_for_credentials
        write_credentials
        check
      rescue Exception => e
        delete_credentials
        raise e
      end
      @credentials
    end

    def delete_credentials
      netrc.delete(host)
      netrc.save
      @credentials = nil
    end

    def write_credentials
      netrc[host] = self.credentials
      netrc.save
    end

    def ask_for_credentials
      puts "Enter your Heroku credentials."

      print "Email: "
      user = ask

      print "Password (typing will be hidden): "
      password = ask_for_password

      [user,password]
    end

    def ask_for_password
      echo_off
      password = ask
      puts
      echo_on
      return password
    end

    def host
      'sidereel.com'
    end

    def check
      client = SidereelClient.new *self.credentials
      p client.tracked_tv_shows
    end

  end
end
