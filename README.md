# EleventhBot

The real bot. The best bot.

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

### Destiny

```yaml
plugins:
  - destiny
```

Commands: `destiny`, `coin`, `roll`

Flips coins, rolls dice and chooses items randomly from lists.

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

Prevents users matching masks from using commands.

### Lastfm

```yaml
plugins:
  - lastfm

lastfm:
  token: 00000000000000000000000000000000
  secret: 00000000000000000000000000000000
  pstore: lastfm.pstore # File to store user associations in
  chart: lastfm.chart # File to cache artist charts in
```

Commands: `assoc`, `assoc?`, `last`, `inform`, `first`, `compare`,
`bestfriend`, `hipster`, `hipsterbattle`, `topartists`, `topalbums`,
`toptracks`

Fetches information from [Last.fm](http://www.last.fm). A Last.fm API
account is required, and can be created
[here](http://www.last.fm/api/account/create).

### Sed

```yaml
plugins:
  - sed

sed:
  memory: 5 # Number of previous lines to remember
```

Provides sed-like modification of previous lines using `s/ma/re/`
syntax.

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
