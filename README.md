echonest
========
Welcome to the foundation for your Echo Nest application.

You will want to create a `settings.rb` file with the following:

```
API_KEY='yourechonestapikey'
```

Get an Echo Nest API key by visiting the (Echo Nest Developer Site)[https://developer.echonest.com/account/register].

Try a few methods out once you have your `settings.rb` file set up...

```
require './song'
s = Song.new
s.search(:artist => 'green day')
require './artist'
a = Artist.new
a.search(:name => ['green day'])
require './playlist'
p = Playlist.new
p.static(:artist => ['green day'])
```

Additional methods and documentation with arguments can be found in

```
app/models/song.rb
app/models/artist.rb
app/models/playlist.rb
```

That's it! Have fun!
