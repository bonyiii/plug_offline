# PlugOffline

[![Build Status](https://travis-ci.org/bonyiii/plug_offline.svg?branch=master)](https://travis-ci.org/bonyiii/plug_offline)

This plug tries to mimic [wycats/rack-offline](https://github.com/wycats/rack-offline) gem's behaviour in elixir. Read its description first, it explains a lot.

Word of warning: Application cache [already deprecated](https://developer.mozilla.org/en-US/docs/Web/HTML/Using_the_application_cache) but the alternative [service workers](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API) is experimental.

Though Application Cache has some issues, it still widely supported, check browser for [service workers](http://caniuse.com/#feat=serviceworkers) and [application cache](http://caniuse.com/#feat=offline-apps) 

## Usage

Add the following lines to: lib/my_app/endpoint.ex

```elixir
  plug Plug.PlugOffline,
  at: "/cache.manifest",
  cache: [],
  network: [],
  fallback: []

``` 

key | mandatory | value | example 
----|-----------|-------|--------
at  | X | at this url will cache manifest file provided eg: www.myapp.com/cache.manifest | "/cache.manifest"
cache | X |list of files that should be in the cache | ["js/app.js", "css/app.css"]
network |  | list of endopoints which are available only when app is online | ["/api"]
fallback |  |what to provide instead of large assets when app offline | ["images/large/ images/offline.jpg"]

Then in web/templates/layout/app.html add/replace the following lines

```html
<html manifest="/cache.manifest">
 ... your content ...
</html>
```

PlugOffline only support, for the time being, the SHA generating strategy (strategy 2. in rack-offline)
which generates a SHA hash once based on the contents of
all the assets in the manifest. This means that the cache manifest will
not be considered stale unless the underlying assets change.

A [good tutorial](http://www.html5rocks.com/en/tutorials/appcache/beginner/) for Application Cache


## Installation

Currently only available through github:

  1. Add plug_offline to your list of dependencies in `mix.exs`:

        def deps do
          [{:plug_offline, github: "bonyiii/plug_offline"}]
        end

  2. Ensure plug_offline is started before your application:

        def application do
          [applications: [:plug_offline]]
        end

