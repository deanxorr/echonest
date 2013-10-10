require "#{Dir.pwd}/settings"
require 'open-uri'
require 'json'


class Playlist
  # this class wraps the EchoNest Playlist API: http://developer.echonest.com/docs/v4/playlist.html
  ARRAY_KEYS = [ :artist, :bucket ]
  REQUIRED = [ :artist ]

  def initialize
    @api_key = API_KEY
    @base_url = "http://developer.echonest.com/api/v4"
  end

  def static(opts={})
    # Returns a list of the foreign ids (i.e. other music services ids) for tracks. 
    #
    # This is fantastic when combined with the spotify embedded player
    # https://developer.spotify.com/technologies/spotify-play-button/
    #
    # required:
    #   artist  => an array of artist names to base the playlist off of
    # optional:
    #   type    => the type of playlist to generate. Default is 'artist', which is a playlist of songs by a single artist
    #              Valid values are: artist, artist-radio, artist-description, song-radio, catalog, catalog-radio, genre-radio
    #   results => desired number of songs in the playlist
    # other optional parameters can be found on the EchoNest Playlist API website here: http://developer.echonest.com/docs/v4/playlist.html
    raise ArgumentError, ":artist is required to generate a playlist" unless opts.keys.include?(:artist)
    query = "/playlist/static?"
    default_opts = {
      :bucket => ['id:spotify-WW', 'tracks'],
      :limit => true,
      :type => 'artist',
    }
    resp = request(build_url(query, default_opts.merge(opts)))
    resp['songs'].map { |track_hash| (track_hash['tracks'][0]['foreign_id']).gsub!("spotify-WW","spotify") }
  end


  private

  def request(url)
    begin
      uri = URI.parse(url + api_string)
      f = JSON.parse(uri.read)
      return f['response']
    rescue => e
      puts "encountered #{e.inspect}. Bad URL was #{url}"
    end
  end

  def build_url(query, opts={})
    handle_opts(opts)
    url = "#{base_url}" << query
    opts.each do |k,v|
      if ARRAY_KEYS.include?(k)
        v.each do |val|
          sub_and_add(url, k, val)
        end
      else
        sub_and_add(url, k, v)
      end
    end
    url
  end

  def sub_and_add(url, k, v)
    value = v.is_a?(String) ? ( v.gsub!(" ", "\+") || v ) : v
    url << "&#{k}=#{value}"
  end

  def handle_opts(opts)

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