require 'launchy'

class Launchy::Application
  #
  # The class handling the browser application and all of its schemes
  #
  class General < Launchy::Application
    def self.handles?(uri)
      true
    end

    def windows_app_list
      ['start /b']
    end

    def cygwin_app_list
      ['cmd /C start /b']
    end

    def darwin_app_list
      [find_executable("open")]
    end

    def nix_app_list
      %w[ xdg-open ]
    end

    # use a call back mechanism to get the right app_list that is decided by the
    # host_os_family class.
    def app_list
      host_os_family.app_list(self)
    end

    def cmd
      possibilities = app_list.flatten
      possibilities.each do |p|
        Launchy.log "#{self.class.name} : possibility : #{p}"
      end
      if (cmdline = possibilities.shift)
        Launchy.log "#{self.class.name} : Using browser value '#{cmdline}'"
        return cmdline
      end
      raise Launchy::CommandNotFoundError, "Unable to find a browser command. If this is unexpected, #{Launchy.bug_report_message}"
    end


    def open(uri, options = {})
      run(cmd, uri)
    end
  end
end
