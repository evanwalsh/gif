require 'thor'
require 'etc'
require 'yaml'
require 'fuzzy_match'
require 'pry'

module GIF
  class CLI < Thor
    desc "setup OPTIONS", "Set the options for gif"
    option :directory
    option :prefix
    def setup
      config['directory'] = options[:directory] 
      config['prefix'] = options[:prefix] 
      save_settings
    end
    
    desc "random", "Get a random GIF"
    def random
      gif = all_gifs.sample
      copy_to_clipboard url_for(gif)
      say "Copied URL for #{gif} to your clipboard"
    end

    desc "search STRING", "Search for a GIF"
    def search(string)
      gifs = FuzzyMatch.new(all_gifs)
      gif = gifs.find(string)
      
      if gif
        copy_to_clipboard url_for(gif)
        say "Found #{gif}. Copied URL to clipboard."
      end
    end

    private
    def all_gifs
      Dir["#{gif_directory}/**/*.gif"].map{|path| path.gsub(gif_directory + "/", '')  } 
    end

    def gif_directory
      config.fetch('directory'){ File.join(Dir.home(Etc.getlogin), 'Dropbox', 'Public', 'Gifs') }
    end

    def url_for(gif)
      %(#{config['prefix']}/#{gif})
    end

    def copy_to_clipboard(string)
      %x(echo "#{string}" | pbcopy)
    end

    def config
      @config ||= (File.exists?(config_path) ? YAML.load_file(config_path) : Hash.new)
    end

    def save_settings
      yml = YAML.dump(@config)
      File.open(config_path, 'w') {|f| f.write(yml) }
    end

    def config_path
      File.join(Dir.home(Etc.getlogin), ".gif.yml")
    end
  end
end
