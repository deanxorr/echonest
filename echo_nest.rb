require "#{Dir.pwd}/settings"
require 'open-uri'
require 'json'

class EchoNest
  VALID_BUCKETS = [ "audio_summary", "artist_familiarity", "artist_hotttnesss", "artist_location", "song_hotttnesss", "song_type", "tracks", "id:rosetta-catalog", "id:Personal-Catalog-ID" ]
  VALID_SORTS   = [ "tempo-asc", "duration-asc", "loudness-asc", "artist_familiarity-asc", "artist_hotttnesss-asc", "artist_start_year-asc", "artist_start_year-desc", "artist_end_year-asc", "artist_end_year-desc", "song_hotttness-asc", "latitude-asc", "longitude-asc", "mode-asc", "key-asc", "tempo-desc", "duration-desc", "loudness-desc", "artist_familiarity-desc", "artist_hotttnesss-desc", "song_hotttnesss-desc", "latitude-desc", "longitude-desc", "mode-desc", "key-desc", "energy-asc", "energy-desc", "danceability-asc", "danceability-desc" ]

  def initialize
    @api_key = API_KEY
    @secret = SECRET
    @consumer_key = CONSUMER_KEY
    @base_url = "http://developer.echonest.com/api/v4"
  end

  def find_songs(opts = {})
    # Returns a list of song hashes for the artist specified. If the connection fails
    # an error message is printed.
    #
    # Optional arguments:
    #   artist  => an artist to search for
    #   bucket  => return additional information about the song. Options are:  
    #       audio_summary | artist_familiarity | artist_hotttnesss | artist_location | 
    #       song_hotttnesss |  song_type | tracks | id:rosetta-catalog | 
    #       id:Personal-Catalog-ID
    #   results => the number of results to display
    #   sort    => option for how to sort the search results. Options are:
    #       tempo-asc | duration-asc | loudness-asc | artist_familiarity-asc | 
    #       artist_hotttnesss-asc | artist_start_year-asc | artist_start_year-desc | 
    #       artist_end_year-asc | artist_end_year-desc | song_hotttness-asc | latitude-asc | 
    #       longitude-asc | mode-asc | key-asc | tempo-desc | duration-desc | loudness-desc |
    #       artist_familiarity-desc | artist_hotttnesss-desc | song_hotttnesss-desc | 
    #       latitude-desc | longitude-desc | mode-desc | key-desc | energy-asc |
    #       energy-desc | danceability-asc | danceability-desc
    #   start   => result number to start at
    #
    # Example:
    #   find_songs_by(
    #     :artist => 'prince', 
    #     :start => 10, 
    #     :results => 50, 
    #     :sort => 'song_hotttnesss-desc', 
    #     :bucket => 'audio_summary'
    #   )
    #
    #   will show results 11 - 60 for a search for songs by Prince, with the hotttessst 
    #   songs earlier in the search results, and will include an audio summary for each
    #   result.
    #
    # These are only some of the capabilities of the EchoNest API; more documentation 
    # can be found here:
    #     http://developer.echonest.com/docs/v4/song.html
    query = "/song/search?"
    request(build_url(query, opts))
  end

  def get_song_profile(id, opts={})
    query = "/song/profile?"
    opts[:id] = id
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
    (opts[:artist] = opts[:artist].gsub!(" ", "\+") || opts[:artist]) if opts[:artist]
    url = "#{base_url}" << query
    opts.each do |k,v|
      url << "&#{k}=#{v}"
    end
    url
  end

  def handle_opts(opts)
    raise ArgumentError, "bucket must be (audio_summary | artist_familiarity | artist_hotttnesss | artist_location | song_hotttnesss | song_type | tracks | id:rosetta-catalog | id:Personal-Catalog-ID)" if (opts[:bucket] && !VALID_BUCKETS.include?(opts[:bucket]))
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