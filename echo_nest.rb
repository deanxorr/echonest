require "#{Dir.pwd}/settings"
require 'open-uri'
require 'json'

class EchoNest
  def initialize
    @api_key = API_KEY
    @secret = SECRET
    @consuemr_key = CONSUMER_KEY
    @base_url = "http://developer.echonest.com/api/v4"
  end

  def find_songs_by(artist, opts={})
    # Returns a list of song hashes for the artist specified. If the connection fails
    # an error message is printed.
    #
    # Optional arguments:
    #   start   => result number to start at
    #   results => the number of results to display
    #   sort    => option for how to sort the search results
    #   bucket  => return additional information about the song
    #
    # Example:
    #   find_songs_by('prince', :start => 10, :results => 50, :sort => 'song_hotttnesss-desc', :bucket => 'audio_summary')
    #
    # will show results 11 - 60 for a search for songs by Prince, with the hotttessst songs earlier
    # in the search results.
    #
    # These are only some of the capabilities of the EchoNest API; more documentation can be found here:
    #    http://developer.echonest.com/docs/v4/song.html
    query = "/song/search?"
    opts[:artist] = artist.gsub!(" ", "\+") || artist

    url = build_url(query, opts)
    # url = "#{base_url}#{query}artist=#{artist_string}"
    # url << "&sort=#{opts[:sort]}"       if opts[:sort]
    # url << "&start=#{opts[:start]}"     if opts[:start]
    # url << "&results=#{opts[:results]}" if opts[:results]
    # url << "&bucket=#{opts[:bucket]}"   if opts[:bucket]
    request(url)
  end

  def get_song_profile(id, opts={})
    query = "/song/profile?"
    opts[:id] = id
    url = build_url(query, opts)
    request(url)
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
    url = "#{base_url}" << query
    opts.each do |k,v|
      url << "&#{k}=#{v}"
    end
    url
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