###
  Entry point
  ===========

  Entry point for the server-side. INCOMPLETE

  ## Contributors
  Steven Enamakel <me@steven.pw>
###

IoC      = require "electrolyte"
bootable = require "bootable"
express  = require "express"
igloo    = require "igloo"
path     = require "path"


# helper functions to properly resolve paths and libraries
_path = (newpath) -> path.join __dirname, newpath
_library = (newpath) -> IoC.node _path newpath


###
  # Dependency Initialization
  Here we include the different components that we want to include in our app.
  Note that this project was initialized using
  [eskimo](https://github.com/niftylettuce/eskimo) and a good deal of code
  lies there (Especially the code to setup the server itself).

  Visit [igloo's documentation page](https://www.npmjs.com/package/igloo) to
  get more info about how it works.
###

# Load the basic app components
IoC.loader "api",         _library "api"
IoC.loader "controllers", _library "controllers"
IoC.loader "cron",        _library "cron"
IoC.loader "errors",      _library "errors"
IoC.loader "libraries",   _library "libraries"
IoC.loader "models",      _library "models"

# Load all igloo components.
IoC.loader                _library "../config"
IoC.loader "igloo",       igloo


###
  # Boot definition
  At this point, electrolyte will have scanned all our source code and created
  proper dependency maps. So to understand how control now goes, follow the
  `app.phase` lines below.

  NOTE: If you don't understand how `bootable` or `bootable.di.initializer`
  works then I recommend reading their
  [source code on github](https://github.com/jaredhanson/bootable/blob/master/lib/phases/initializers.js).

  1. At first all scripts in `init/pre` are executed and then the app is
  initialized by igloo (using `igloo/server`).
  2. When the app is set, it is now listening to the routes that we have defined
  and will start executing based on which ones get fired.
  3. We also keep some scripts in `init/post` if we need
  to run anything after the app has been set.
###

# Use bootable to create our app.
app = bootable express()

# Run the 'before initializing' scripts.
app.phase bootable.di.initializers _path "init/pre"

# Initialize the app.
app.phase bootable.di.routes       _path "routes"
app.phase IoC.create                     "igloo/server"

# Run the 'after initialization' scripts.
app.phase bootable.di.initializers _path "init/post"


###
  # Finish
  Now the app has been properly defined, with all boot phases and dependencies
  wired up. But the app doesn't really start here. To really start the
  app, we need to call `app.boot()`, which is done in the `bin/server.coffee`
  file.

  For now we'll just hand over the app to whoever wants it (Useful if we are
  running some test-suites).
###
module.exports = app