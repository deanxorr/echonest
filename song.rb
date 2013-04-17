require "#{Dir.pwd}/settings"
require 'open-uri'
require 'json'

module EchoNest
  class Song
    # this class wraps the EchoNest Song API: http://developer.echonest.com/docs/v4/song.html
    VALID_BUCKETS = [ "audio_summary", "artist_familiarity", "artist_hotttnesss", "artist_location", "song_hotttnesss", "song_type", "tracks", "id:rosetta-catalog", "id:Personal-Catalog-ID" ]
    VALID_SORTS   = [ "tempo-asc", "duration-asc", "loudness-asc", "artist_familiarity-asc", "artist_hotttnesss-asc", "artist_start_year-asc", "artist_start_year-desc", "artist_end_year-asc", "artist_end_year-desc", "song_hotttness-asc", "latitude-asc", "longitude-asc", "mode-asc", "key-asc", "tempo-desc", "duration-desc", "loudness-desc", "artist_familiarity-desc", "artist_hotttnesss-desc", "song_hotttnesss-desc", "latitude-desc", "longitude-desc", "mode-desc", "key-desc", "energy-asc", "energy-desc", "danceability-asc", "danceability-desc" ]

    def initialize
      @api_key = API_KEY
      @base_url = "http://developer.echonest.com/api/v4"
    end

    # This prevents our api key from being output when the class is initialized or 
    # printed out
    def inspect
      "API key hidden for protection. Using the target URL #{@base_url}"
    end

    def search(opts = {})
      # Returns a list of song hashes for the artist specified.
      # Example: 
      # search(
      #   :title => 'american idiot', 
      #   :artist => 'green day', 
      #   :description => 'rock',
      #   :song_type => 'studio',
      #   :min_tempo => '60.0',
      #   :min_duration => '180',
      #   :artist_min_familiarity => 0.3,
      #   :min_energy => 0.1,
      #   :sort => "tempo-desc"
      #   )
      #
      # Optional arguments:
      #   title                        => title of the song
      #   artist                       => an artist to search for
      #   bucket                       => An array of one or more of VALID_BUCKETS
      #   combined                     => send to both title and artist fields
      #   description                  => description of the artist (genre, mood, etc)
      #   style                        => specify a style for the artist
      #   mood                         => specify a mood for the artist
      #   results                      => the number of results to display
      #   song_type                    => (christmas|live|studio)
      #   (min|max)_tempo              => (min|max) BPM to return (0 - 500)
      #   (min|max)_duration           => (min|max) duration of any song in seconds (0 - 3600)
      #   (min|max)_loudness           => (min|max) loudess of song in dB (-100.0 - 100.0)
      #   artist_(min|max)_familiarity => (min|max)imum familiarity of song's artist ( 0.0 - 1.0 )
      #   song_(min|max)_hotttnesss    => (min|max)imum hotttnesss of any song ( 0.0 - 1.0 )
      #   artist_(min|max)_hotttnesss  => (min|max) hotttnesss of any song's artist ( 0.0 - 1.0 )
      #   (min|max)_longitude          => the (min|max) longitude of the primary artists location
      #   (min|max)_latitude           => the (min|max) longitude of the primary artists location
      #   (min|max)_danceability       => the (min|max) danceability of any song ( 0.0 - 1.0 )
      #   (min|max)_energy             => the (min|max) energy of any song ( 0.0 - 1.0 )
      #   mode                         => mode of the song (minor | major)
      #   key                          => musical key of the song
      #   sort                         => see VALID_SORTS
      #   start                        => result number to start at
      query = "/song/search?"
      request(build_url(query, opts))
    end

    def profile(opts={})
      # Get info about songs given a song id
      # example: profile(:id => 'SOSPBCX13740AAB86C')
      #
      # required (one of):
      #   id                    => a song's echonest or rosetta id
      #   track_id              => a track's echonest or rosetta id
      # optional:
      #   bucket                => see VALID_BUCKETS Values: bucket | [list, of, buckets]
      #   limit                 => whether or not to limit to any given id spaces or catalogs
      raise ArgumentError, ":id is a required field" unless opts[:id]
      query = "/song/profile?"
      request(build_url(query, opts))
    end

    private
    def request(url)
      begin
        uri = URI.parse(url + api_string)
        f = JSON.parse(uri.read)
        return f['response']['songs']
      rescue => e
        puts "encountered #{e.inspect}. Bad URL was #{url}"
      end
    end

    def build_url(query, opts={})
      handle_opts(opts)
      url = "#{base_url}" << query
      opts.each do |k,v|
        value = ( v.gsub!(" ", "\+") || v )
        url << "&#{k}=#{value}"
      end
      url
    end

    def handle_opts(opts)
      raise ArgumentError, "bucket must be (audio_summary | artist_familiarity | artist_hotttnesss | artist_location | song_hotttnesss | song_type | tracks | id:rosetta-catalog | id:Personal-Catalog-ID)" if (opts[:bucket] && opts[:bucket].detect {|l| !VALID_BUCKETS.include?(l) })
      raise ArgumentError, "sort must be ( tempo-asc | duration-asc | loudness-asc | artist_familiarity-asc | artist_hotttnesss-asc | artist_start_year-asc | artist_start_year-desc | artist_end_year-asc | artist_end_year-desc | song_hotttness-asc | latitude-asc | longitude-asc | mode-asc | key-asc | tempo-desc | duration-desc | loudness-desc | artist_familiarity-desc | artist_hotttnesss-desc | song_hotttnesss-desc | latitude-desc | longitude-desc | mode-desc | key-desc | energy-asc | energy-desc | danceability-asc | danceability-desc )" if (opts[:sort] && !VALID_SORTS.include?(opts[:sort]))
    end

    def api_string
      "&api_key=#{api_key}"
    end

    def base_url
      @base_url
    end

    def api_key
      @api_key
    end
  end
end