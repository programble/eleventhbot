# EleventhBot

The real bot. The best bot.

## Setup

First, fetch the dependencies.

```sh
bundle install
```

You can use Bundler's `--without` option to leave out dependencies of
plugins you don't plan to use.

```sh
bundle install --without lastfm
```

Next, create a configuration file and edit accordingly.

```sh
cp eleventhbot.yml.example eleventhbot.yml
```

Details on available plugins and their configurations can be found in
the section below.

Now that EleventhBot is configured, run it.

```sh
bin/eleventhbot
```

## Plugins

### Acronym

```yaml
plugins:
  - acronym

acronym:
  words: /usr/share/dict/words
```

Commands: `acronym`

Suggests possible meanings of acronyms.

### Admin

```yaml
plugins:
  - admin

admin:
  masks:
    - '*!*example@example.com'
  eval: false # Enable the eval command. Do not enable this. Just don't.
```

Commands: `say`, `action`, `nick`, `join`, `part`, `plugins`, `enable`,
`disable`, `reload`

Provides administrative commands.

### Automeme

```yaml
plugins:
  - automeme
```

Commands: `meme`, `automeme`

Uses the [Automeme.net](http://automeme.net) API to generate random
memes.

### Channels

```yaml
plugins:
  - channels

channels:
  blacklist:
    plugin: ['#example'] # Plugin will not work in #example
  whitelist:
    plugin: ['#example'] # Plugin will only work in #example
```

Admin commands: `blacklists`, `whitelists`, `blacklist`, `whitelist`,
`unblacklist`, `unwhitelist`

Disables plugins in certain channels.

### Destiny

```yaml
plugins:
  - destiny
```

Commands: `destiny`, `coin`, `roll`, `draw`

Flips coins, rolls dice, draws cards and chooses items randomly from lists.

### Fedora

```yaml
plugins:
  - fedora
```

Commands: `pkgwat`

Provides information about Fedora. e.g., package versions against releases.

### Freebase

```yaml
plugins:
  - freebase

freebase:
  key: 000000000000000000000000000000000000000
```

Commands: `info`

Retrieves information from Freebase. An API key is optional and can be
obtained from [Google APIs
Console](https://code.google.com/apis/console).

### Github

```yaml
plugins:
  - github
```

Commands: `ghstatus`

Gets Github Status information.

### Help

```yaml
plugins:
  - help
```

Commands: `list`, `provides?`, `help`

Provides access to help topics.

### Ignore

```yaml
plugins:
  - ignore

ignore:
  masks:
    - '*!*example@example.com'
```

Admin commands: `ignores`, `ignore`, `unignore`

Prevents users matching masks from using commands.

### Karma

```yaml
plugins:
  - redis
  - karma
```

Commands: `karma`

Keeps track of karma increased by "thing++" and decreased by "thing--".

### Lastfm

```yaml
plugins:
  - redis
  - lastfm

lastfm:
  token: 00000000000000000000000000000000
  secret: 00000000000000000000000000000000
```

Commands: `assoc`, `assoc?`, `last`, `inform`, `first`, `compare`,
`bestfriend`, `hipster`, `hipsterbattle`, `topartists`, `topalbums`,
`toptracks`

Fetches information from [Last.fm](http://www.last.fm). A Last.fm API
account is required, and can be created
[here](http://www.last.fm/api/account/create).

### Network

```yaml
plugins:
  - network
```

Commands: `host`, `dns`

Provides information about network-related things. e.g., DNS lookups.

### Meep

```yaml
plugins:
  - meep
```

Dummy plugin.

### Rate Limit

```yaml
plugins:
  - ratelimit

ratelimit:
  rate: 5
  time: 1 # seconds
  cooldown: 5
```

Limits the number of commands that can be run in a period of time.

### Redis

```yaml
plugins:
  - redis

redis:
  uri: redis://localhost:6379/0
```

Provides a connection to a [Redis](http://redis.io) server to other
plugins.

### Sed

```yaml
plugins:
  - sed

sed:
  memory: 5 # Number of previous lines to remember
```

Provides sed-like modification of previous lines using `s/ma/re/`
syntax.

### Snarf

```yaml
plugins:
  - snarf

snarf:
  timeout: 5 # seconds
  http:
    limits:
      redirects: 5
      stream: 512 # kilobytes
      title: 250 # characters
    useragent: 'Mozilla/5.0 (X11; Linux x86_64; rv:24.0) Gecko/20100101 Firefox/24.0'
    shorten: 35 # URI length to shorten
  twitter: # Optional
    key: 000000000000000000000
    secret: 0000000000000000000000000000000000000000000
```

Retrieves titles for HTML links, reports dimensions of links to images,
gives specialized output for GitHub repositories, and optionally retrieves
tweet information and text for Twitter status links. A Twitter API key can be
obtained from [Twitter Developers](https://dev.twitter.com/apps/new).

### Spell

```yaml
plugins:
  - spell

spell:
  checker: hunspell # hunspell or aspell
  language: en_US
```

Commands: `spell`

Uses [Hunspell](http://hunspell.sourceforge.net) or
[Aspell](http://aspell.net) to correct spelling. The selected checker
and dictionary must be installed.

## License

Copyright © 2013, Curtis McEnroe <programble@gmail.com>

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
