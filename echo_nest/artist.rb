require "#{Dir.pwd}/settings"
require 'open-uri'
require 'json'

module EchoNest
  class Artist
    # this class wraps the EchoNest Artist API: http://developer.echonest.com/docs/v4/artist.html
    ARRAY_KEYS = [:license, :bucket, :name, :id, :description, :genre, :style, :mood]
    VALID_LICENSES = [ "echo-source", "all-rights-reserved", "cc-by-sa", "cc-by-nc", "cc-by-nc-nd", "cc-by-nc-sa", "cc-by-nd", "cc-by", "public-domain", "unknown" ]
    VALID_HOTTTNESSS = [ "overall", "social", "reviews", "mainstream" ]
    VALID_BUCKETS = [ "biographies", "blogs", "doc_counts", "familiarity", "hotttnesss", "images", "artist_location", "news", "reviews", "songs", "terms", "urls", "video", "years_active", "id:Rosetta-space" ]
    VALID_SORTS = [ "familiarity-asc", "hotttnesss-asc", "familiarity-desc", "hotttnesss-desc", "artist_start_year-asc", "artist_start_year-desc", "artist_end_year-asc", "artist_end_year-desc" ]

    def initialize
      @api_key = API_KEY
      @base_url = "http://developer.echonest.com/api/v4"
    end

    def biographies(opts={})
      # Returns an array of biographies for an artist
      # Example: biographies(:name => ["green day"], :results => 1, :start => 0)
      #
      # one of these is required:
      #   name           => Find artist by their name (provided as an array)
      #   id             => Find artist by the echo nest api id (provided as an array)
      # optional:
      #   results        => return this many results.             Values: 0..100
      #   start          => start at the nth result.              Values: 0..n
      #   license        => array of licenses to select for       Values: VALID_LICENSES
      raise ArgumentError if ( (opts[:name] && opts[:id]) || (!opts[:name] && !opts[:id]) )
      query = "/artist/biographies?"
      request(build_url(query, opts))['biographies']
    end

    def blogs(opts={})
      # Returns an array of blogs that mention an artist
      # Example: blogs(:name => ["green day"], :high_relevance => true, :results => 50)
      #
      # one of these is required:
      #   name           => Find artist by their name (provided as an array)
      #   id             => Find artist by the echo nest api id (provided as an array)
      # optional:
      #   results        => return this many results.            Values: 0..100
      #   start          => start at the nth result.             Values: 0..n
      #   high_relevance => return only highly relevant results. Values: true | false
      query = "/artist/blogs?"
      request(build_url(query, opts))['blogs']
    end

    # BETA
    def extract(opts={})
      # Attempts to extract artist names from given text
      # Example extract(:text => "green day put on a ridiculous show", :min_hotttnesss => 0.5)
      #
      # required
      #   text                  => the text to parse
      # optional
      #   min/max hotttnesss    => minimum or maximum hotttnesss Value: 0.0 < hotttnesss < 1.0
      #   min/max familiarity   => minimum or maximum familiarity Value: 0.0 < familiarity < 1.0
      #   sort                  => see VALID_SORTS
      #   bucket                => see VALID_BUCKETS Values: bucket | [list, of, buckets]
      #   results               => the number of results to return
      #   limit                 => whether or not to limit to any given id spaces or catalogs
      raise ArgumentError, "must supply text" unless opts[:text]
      raise ArgumentError, "sort must be in #{VALID_SORTS}" unless ( opts[:sort] && !VALID_SORTS.include?(opts[:sort]) )
      query = "/artist/extract?"
      request(build_url(query, opts))['artists']
    end

    def familiarity(opts={})
      # Returns EchoNest's measure of how familiar an artist is to the world
      #
      # one of these is required:
      #   name           => Find artist by their name (provided as an array)
      #   id             => Find artist by the echo nest api id (provided as an array)
      raise ArgumentError, "either name or id needs to be provided" if ( !opts[:id] && !opts[:name] )
      query = "/artist/familiarity?"
      request(build_url(query, opts))['artist']
    end

    def hotttnesss(opts={})
      # Return an artist's 'hotttnesss'
      # Example: hotttnesss(:id => ["ARV3CRH1187B9A1B21"], :type => 'overall')
      #
      # one of these is required:
      #   name           => Find artist by their name (provided as an array)
      #   id             => Find artist by the echo nest api id (provided as an array)
      # optional
      #   type           => Type of hotttnesss used. Value: ( overall | social | reviews | mainstream )
      raise ArgumentError, "either name or id needs to be provided" if ( !opts[:id] && !opts[:name] )
      query = "/artist/hotttnesss?"
      request(build_url(query, opts))['artist']
    end

    def images(opts={})
      # Returns an array of images for an artist
      # Example: images(:name => ["green day"], :start => 0, :results => 1)
      #
      # one of these is required:
      #   name           => Find artist by their name (provided as an array)
      #   id             => Find artist by the echo nest api id (provided as an array)
      # optional:
      #   results        => return this many results.             Values: 0..100
      #   start          => start at the nth result.              Values: 0..n
      #   license        => only return results with this license Values: VALID_LICENSES
      raise ArgumentError, "either name or id needs to be provided" if ( !opts[:id] && !opts[:name] )
      query = "/artist/images?"
      request(build_url(query, opts))['images']
    end

    def list_genres
      # returns an array of genres
      # Example: list_genres
      #
      query = "/artist/list_genres?"
      request(build_url(query, {}))['genres'].map {|g| g['name']}
    end

    def list_terms(opts={})
      # returns an array of terms that can be used for searching
      # Example: list_terms(:type => 'style')
      #
      # optional
      #   type  => the type of term to return  Value: ( style | mood )
      query = "/artist/list_terms?"
      request(build_url(query, opts))['terms'].map {|g| g['name']}
    end

    def news(opts={})
      # Returns an array of news items that mention an artist
      # Example: news(:name => ["green day"], :start => 0, :results => 1, :high_relevance => true)
      #
      # one of these is required:
      #   name           => Find artist by their name (provided as an array)
      #   id             => Find artist by the echo nest api id (provided as an array)
      # optional:
      #   results        => return this many results.            Values: 0..100
      #   start          => start at the nth result.             Values: 0..n
      #   high_relevance => return only highly relevant results. Values: true | false
      query = "/artist/news?"
      request(build_url(query, opts))['news']
    end

    def profile(opts={})
      # Returns the basic information about the artist including name, echonest id, and 
      # musicbrainz id
      # Example: profile(:name => ["green day"], :bucket => ['doc_counts','hotttnesss'])
      #
      # one of these is required:
      #   name           => Find artist by their name (provided as an array)
      #   id             => Find artist by the echo nest api id (provided as an array)
      # optional:
      #   bucket         => additional data to be returned. Values: ( biographies | 
      #                     blogs | doc_counts | familiarity | hotttnesss | images | 
      #                     artist_location | news | reviews | songs | terms | urls | 
      #                     video | years_active | id:Rosetta-space | [list, of, buckets])
      query = "/artist/profile?"
      request(build_url(query, opts))['artist']
    end

    def reviews(opts={})
      # Returns an array of reviews of an artist
      # Example: reviews(:id => ["ARV3CRH1187B9A1B21"], :results => 1, :start => 0)
      #
      # one of these is required:
      #   name           => Find artist by their name (provided as an array)
      #   id             => Find artist by the echo nest api id (provided as an array)
      # optional:
      #   results        => return this many results.            Values: 0..100
      #   start          => start at the nth result.             Values: 0..n
      query = "/artist/reviews?"
      request(build_url(query, opts))['artist']
    end

    def search(opts={})
      # Searches for artists that fit the given criteria
      # Example: search(:name => ["green day"], :bucket => 'urls', :sort => hotttnesss-desc, :genre => 'rock', min_hotttnesss => 0.5, artist_end_year_after => 'present')
      #
      # optional:
      #   name                     => Find artist by their name (provided as an array)
      #   bucket                   => additional data to be returned. Values: 
      #                               ( biographies | blogs | doc_counts | familiarity | 
      #                               hotttnesss | images | artist_location | news | 
      #                               reviews | songs | terms | urls | video | 
      #                               years_active | id:Rosetta-space )
      #   sort                     => sort order. Values: ( familiarity-asc | 
      #                               hotttnesss-asc | familiarity-desc | hotttnesss-desc | 
      #                               artist_start_year-asc | artist_start_year-desc | 
      #                               artist_end_year-asc | artist_end_year-desc )
      #   limit                    => limit the results to any given id spaces or catalogs. 
      #                               Values: ( true | false )
      #   artist_location (beta)   => location of an artist. Values: boston+ma+us, city:name, 
      #                               region:name, country:long+name 
      #   description              => list of descriptions of the music 
      #                               Values: alt-rock, -emo, harp^2, etc.
      #   genre                    => list of genres that describe the 
      #                               artist Values: jazz, metal^2 etc.
      #   style                    => list of styles that describe the 
      #                               artist Values: jazz, metal^2 etc.
      #   mood                     => list of moods that describe the 
      #                               artist Values: happy, sad^.5, etc.
      #   rank_type                => for description, style, or mood searches, specify whether 
      #                               results will be ranked by relevance or familiarity 
      #                               Values: ( relevance | familiarity )
      #   fuzzy_match              => whether or not a fuzzy search will be performed 
      #                               Value: ( true | false )
      #   max_familiarity          => max familiarity for results Values: 0.0 < familiarity < 1.0
      #   min_familiarity          => min familiarty for results Values: 0.0 < familiarity < 1.0
      #   max_hotttnesss           => max hotttnesss for results Values: 0.0 < hotttnesss < 1.0
      #   min_hotttnesss           => min hotttnesss for results Values: 0.0 < hotttnesss < 1.0
      #   artist_start_year_before => latest start year for results Values: ( 1970..2011 | present )
      #   artist_start_year_after  => earliest start year for results Values: ( 1970..2011 | present )
      #   artist_end_year_before   => latest end year for results Values: ( 1970..2011 | present )
      #   artist_end_year_after    => earliest end year for results Values: ( 1970..2011 | present )
      #   results                  => return this many results. Values: 0..100
      #   start                    => start at the nth result. Values: 0..n
      raise ArgumentError, "sort must be in #{VALID_SORTS}" unless ( opts[:sort] && !VALID_SORTS.include?(opts[:sort]) )
      query = "/artist/search?"
      request(build_url(query, opts))['artists']
    end

    def songs(opts={})
      # Returns an array of songs by an artist
      # Example: songs(:name => ["green day"])
      #
      # one of these is required:
      #   name           => Find artist by their name (provided as an array)
      #   id             => Find artist by the echo nest api id (provided as an array)
      # optional:
      #   results        => return this many results.            Values: 0..100
      #   start          => start at the nth result.             Values: 0..n
      query = "/artist/songs?"
      request(build_url(query, opts))['songs']
    end

    def similar(opts={})
      # Find similar artists given one or more seed artists or albums
      # Example: similar(:name => ["green day", "the ataris", "new found glory"])
      #
      # one of these is required:
      #   name           => seed with up to 5 artists by name as an array
      #   id             => seed with up to 5 artists by id as an array
      # optional:
      #   results        => return this many results.            Values: 0..100
      #   min_results    => return at least this many results.   Values: 0..100
      #   start          => start at the nth result.             Values: 0..n
      #   bucket         => an array of one or more buckets.     Values: see VALID_BUCKETS
      #   min/max familiarity
      #   min/max hotttnesss
      #   artist start/end year before/after
      #   limit          => whether to limit results to id spaces or catalogs. Values: (true|false)
      #   seed_catalog   => seed with one or more catalogs (up to five) as an array
      query = "/artist/similar?"
      request(build_url(query, opts))['artists']
    end

    #BETA
    def suggest(opts={})
      # Find suggestions for artists based on a partial name
      # Example: suggest(:q => 'reen d')
      #
      # required
      #   q       => a partial artist name, e.g. 'beat' for The Beatles
      # optional
      #   results => number of results to return
      raise ArgumentError, "opts[:q] is required" unless opts[:q]
      query = "/artist/suggest?"
      request(build_url(query, opts))['artists']
    end

    def terms(opts={})
      # Find the top terms to describe an artist
      # Example: terms(:name => ["green day"], :sort => 'weight')
      #
      # required
      #   name       => Find artist by their name (provided as an array)
      #   id         => Find artist by their id (provided as an array)
      # optional
      #   sort       => Either order terms by weight or frequency Values: (weight|frequency)
      raise ArgumentError, "sort must be (weight|frequency)" unless ( opts[:sort] && ['weight','frequency'].inclue?(opts[:sort]))
      query = "/artist/terms?"
      request(build_url(query, opts))['terms']
    end

    def top_hottt(opts={})
      # Returns an array of the hotttessst artists according to provided params
      # Example: top_hottt(:genre => ['rock^2', 'alternative'])
      #
      # optional
      #   results => how many results to return
      #   start => which result to start at
      #   genre => array of one or more genres of interest
      #   bucket => array of additional information to provide
      #   limit => Whether or not to limit to any id: buckets, if provided (true|false)
      query = "/artist/top_hottt?"
      request(build_url(query, opts))['artists']
    end

    def top_terms(opts={})
      # Returns an array of the current top terms
      # Example: top_terms(:results => 50)
      #
      # optional
      #   results => how many results to return
      query = "/artist/top_terms?"
      request(build_url(query, opts))['terms']
    end

    def twitter(opts={})
      # Returns the twitter handle for an artist
      # Example: twitter(:name => ["green day"])
      #
      # required
      #   name       => Find artist by their name (provided as an array)
      #   id         => Find artist by their id (provided as an array)
      query = "/artist/twitter?"
      request(build_url(query, opts))['artist']['twitter']
    end

    def urls(opts={})
      # Returns a hash of relevant links for an artist (official site, amazon, etc.)
      # Example: urls(:name => ["green day"])
      #
      # required
      #   name       => Find artist by their name (provided as an array)
      #   id         => Find artist by their id (provided as an array)
      query = "/artist/urls?"
      request(build_url(query, opts))['urls']
    end


    def video(opts={})
      # Returns an array of video documents found on the web for a given artist
      # Example: video(:name => ["green day"])
      #
      # required
      #   name       => Find artist by their name (provided as an array)
      #   id         => Find artist by their id (provided as an array)
      # optional
      #   results    => How many results to return
      #   start      => What result to start at
      query = "/artist/video?"
      request(build_url(query, opts))['videos']
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
      value = ( v.gsub!(" ", "\+") || v )
      url << "&#{k}=#{value}"
    end

    def handle_opts(opts)
      if opts[:license] && opts[:license].detect {|l| !VALID_LICENSES.include?(l) }
        msg = "license must be in #{VALID_LICENSES}"
        raise ArgumentError, msg
      elsif opts[:results] && ( opts[:results].to_i < 1 || opts[:results].to_i > 100 )
        msg = "results must be between 1 and 100"
        raise ArgumentError, msg
      elsif opts[:type] && !VALID_HOTTTNESSS.include?(opts[:type])
        msg = "type must be in #{VALID_HOTTTNESSS}"
        raise ArgumentError, msg
      elsif opts[:bucket] && opts[:bucket].detect {|l| !VALID_BUCKETS.include?(l) }
        msg = "bucket must be in #{VALID_BUCKETS}"
        raise ArgumentError, msg
      end
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