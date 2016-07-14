# PlugOffline

[![Build Status](https://travis-ci.org/bonyiii/plug_offline.svg?branch=master)](https://travis-ci.org/bonyiii/plug_offline)

This plug tries to mimic [wycats/rack-offline](https://github.com/wycats/rack-offline) gem's behaviour in elixir. Read its description first, it explains a lot.

Word of warning: Application cache [already deprecated](https://developer.mozilla.org/en-US/docs/Web/HTML/Using_the_application_cache) but the alternative [service workers](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API) is experimental.

Though Application Cache has some issues, it still widely supported, check browser for [service workers](http://caniuse.com/#feat=serviceworkers) and [application cache](http://caniuse.com/#feat=offline-apps) 

## Usage
Assuming phoenix framework, but should work wihtout it:

Add the following lines to: lib/my_app/endpoint.ex

Parameters are passed in as a map.

```elixir
  plug Plug.PlugOffline, %{
  at: "/cache.manifest",
  base_path: Path.join(Path.dirname(__ENV__.file), "../../priv/static"),
  offline_asset: true,
  cache_digest: true,
  inline: Application.get_env(:my_app, MyApp.Endpoint)[:inline_assets],
  cache: [],
  network: [],
  fallback: [] }

``` 

key | mandatory | value | example 
----|-----------|-------|--------
at  | X | at this url will cache manifest file provided eg: www.myapp.com/cache.manifest | "/cache.manifest"
base_path | X | base path for assets files eg: /js/app.js will be looked up like this /priv/static/js/app.js | Path.join(Path.dirname(__ENV__.file), "../../priv/static")
offline_asset| | use offline assets in views, see optional offline assets section | TRUE/FALSE
cache_digest| | do not regenerate cache manifest on page load | TRUE/FALSE 
inline| | if offline_asset is in use render assets inline or not in views, see examples in offline assets section | TRUE/FALSE
cache | X |list of files that should be in the cache | ["/js/app.js", "/css/app.css"]
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

  1. Add plug_offline to your list of dependencies in `mix.exs`:

        def deps do
          [{:plug_offline, "~> 0.0.3"}]
        end

  2. Ensure plug_offline is started before your application:

        def application do
          [applications: [:plug_offline]]
        end

## Optional

### Offline Assets

Many time when one develop an application using App Cache face the problem that an assets served through HTTPS. This is a must for security but App Cache cannot handle it - at least I was not able to make it work. 

If one tries to use the asset through CDN and HTTP but the app itself served through HTTPS you run into the mixed content error, modern browser gonna report error.

The soultion is to pack everything into one huge HTML file in production.

Using OfflineAssets

web/templates/layout/app.html.eex

````html
<!DOCTYPE html>
<html lang="en" manifest="/cache.manifest">
  <head>
  <%= raw OfflineAsset.css(
      inline: Application.get_env(:my_app, MyApp.Endpoint)[:inline_assets],
      file_path: Path.join([MyApp.Endpoint.config(:root), "/priv/static/css/foundation.min.css"]),
      static_path: static_path(@conn, "/css/foundation.min.css")) %>
  </head>
  <body>
    ... Whatever ...
 </body>
  <%= raw OfflineAsset.js(
      inline: Application.get_env(:my_app, MyApp.Endpoint)[:inline_assets],
      file_path: Path.join([MyApp.Endpoint.config(:root), "/priv/static/js/vendor.bundle.js"]),
      static_path: static_path(@conn, "/js/vendor.bundle.js")) %>
</html>
````

#### Development setup:

conf/dev.exs

```elixir
config :my_app, MyApp.Endpoint,
  inline_assets: false
```

Resulting: 

````html
<!DOCTYPE html>
<html lang="en" manifest="/cache.manifest">
  <head>
   <link href='/css/foundation.min.css', media='all', rel='stylesheet', type='text/css'></link>
  </head>
  <body>
    ... Whatever ...
 </body>
  <script src='/js/vendor.bundle.js'></script>
</html>
````

#### Production setup

conf/prod.exs

```elixir
config :my_app, MyApp.Endpoint,
  inline_assets: true
```

Resulting: 

````html
<!DOCTYPE html>
<html lang="en" manifest="/cache.manifest">
  <head>
   <style>
     .nice: {
      font-weight: bold;
     }
   </stlye>
  </head>
  <body>
    ... Whatever ...
 </body>
  <script>
    console.log("Nice")
  </script>
</html>
````

## Contributors

[@ggpasqualino](https://github.com/ggpasqualino/) 
