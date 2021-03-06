# Generated on 2014-05-31 using generator-ionic 0.3.5
"use strict"
_ = require("lodash")
path = require("path")
cordova = require("cordova")
spawn = require("child_process").spawn
accessAllow = undefined
livereload_port = undefined
lrSnippet = undefined
mountFolder = undefined
livereload_port = 35729
lrSnippet = require("connect-livereload")(port: livereload_port)
accessAllow = (req, res, next) ->
  res.setHeader "Access-Control-Allow-Origin", "*"
  res.setHeader "Access-Control-Allow-Methods", "*"
  next()

mountFolder = (connect, dir) ->
  connect["static"] require("path").resolve(dir)

module.exports = (grunt) ->
  yeomanConfig = undefined
  # Load grunt tasks automatically
  require("load-grunt-tasks") grunt
  # Time how long tasks take. Can help when optimizing build times
  require("time-grunt") grunt
  yeomanConfig =
    app: "app"
    dist: "dist"
  # Define the configuration for all the tasks
  grunt.initConfig
    # Project settings
    yeoman: yeomanConfig
    # Watches files for changes and runs tasks based on the changed files
    watch:
      js:
        files: ["<%= yeoman.app %>/scripts/{,*/}*.js"]
        tasks: ["newer:jshint:all"]
        options:
          livereload: true
      coffee:
        files: ["<%= yeoman.app %>/scripts/{,*/}*.coffee"]
        tasks: [
          "coffee:dist"
          "concat:server"
        ]
        options:
          livereload: false
      less:
        files: ["<%= yeoman.app %>/styles/**/*.less"]
        tasks: "less"
        options:
          livereload: false
      scripts:
        files: ".tmp/scripts/all.js"
      imgs:
        files: "<%= yeoman.app %>/images/**/*.{png,jpg,jpeg,gif,webp,svg}"

      styles:
        files: ["{.tmp,<%= yeoman.app %>}/styles/**/*.css"]
      html:
        files: [
          "{<%= yeoman.app %>,.tmp}/views/*.html"
          "{<%= yeoman.app %>,.tmp}/index.html"
        ]
      jade:
        files: [
          "<%= yeoman.app %>/views/**/*.jade"
          "<%= yeoman.app %>/index.jade"
        ]
        tasks: "jade"
        options:
          livereload: false
      jsTest:
        files: ["test/spec/{,*/}*.js"]
        tasks: [
          "newer:jshint:test"
          "karma"
        ]
      options:
        livereload: true
    # The actual grunt server settings
    connect:
      options:
        port: 9000
        hostname: "127.0.0.1"
        bast: "dist"
      livereload:
        options:
          middleware: (connect) ->
            [
              lrSnippet
              mountFolder(connect, ".tmp")
              mountFolder(connect, yeomanConfig.app)
            ]
    autoprefixer:
      options:
        browsers: ["last 1 version"]
      dist:
        files: [
          expand: true
          cwd: ".tmp/styles/"
          src: "**/*.css"
          dest: ".tmp/styles/"
        ]
    clean:
      dist:
        files: [
          dot: true
          src: [
            ".tmp"
            "<%= yeoman.dist %>/*"
            "!<%= yeoman.dist %>/.git*"
            "www/*"
          ]
        ]
      server: ".tmp"
    less:
      development:
        files:
          ".tmp/styles/hiin.css": "<%= yeoman.app %>/styles/*.less"
    coffee:
      dist:
        files: [
          {
            ".tmp/scripts/app.js": "<%= yeoman.app %>/scripts/app.coffee"
            ".tmp/scripts/controllers.js": "<%= yeoman.app %>/scripts/controllers/*.coffee"
          }
          {
            expand: true
            cwd: "<%= yeoman.app %>/scripts/services"
            src: "**/*.coffee"
            dest: ".tmp/scripts/services"
            ext: ".js"
          }
        ]
    concat:
      server:
        files: [
          ".tmp/scripts/services.js": [
            "app/scripts/services/services.js"
            ".tmp/scripts/services/*.js"
          ]
          ".tmp/scripts/plugins.js": [
            "app/scripts/services/webDb.js"
            "app/scripts/services/PushNotification.js"
            "app/scripts/services/facebookConnectPlugin.js"
          ]
          ".tmp/scripts/all.js": [
            ".tmp/scripts/services.js"
            ".tmp/scripts/app.js"
            ".tmp/scripts/plugins.js"
            ".tmp/scripts/controllers.js"
          ]
        ]

    jade:
      compile:
        files: [
          {
            expand: true
            cwd: "<%= yeoman.app %>/views/"
            src: "**/*.jade"
            dest: ".tmp/views/"
            ext: ".html"
          }
          {
            ".tmp/index.html": "<%= yeoman.app %>/index.jade"
          }
        ]
    "bower-install":
      app:
        html: "<%= yeoman.app %>/index.html"
        ignorePath: "<%= yeoman.app %>/"
    # Renames files for browser caching purposes
    rev:
      dist:
        files:
          src: [
            "<%= yeoman.dist %>/scripts/{,*/}*.js"
            "<%= yeoman.dist %>/styles/{,*/}*.css"
            "<%= yeoman.dist %>/images/{,*/}*.{png,jpg,jpeg,gif,webp,svg}"
            "<%= yeoman.dist %>/styles/fonts/*"
          ]
    useminPrepare:
      html: "<%= yeoman.dist %>/index.html"
      options:
        dest: "<%= yeoman.dist %>"
    # Performs rewrites based on rev and the useminPrepare configuration
    usemin:
      html: ["<%= yeoman.dist %>/{,*/}*.html"]
      css: ["<%= yeoman.dist %>/styles/{,*/}*.css"]
      options:
        assetsDirs: ["<%= yeoman.dist %>"]
    # The following *-min tasks produce minified files in the dist folder
    imagemin:
      dist:
        files: [
          expand: true
          cwd: "<%= yeoman.app %>/images"
          src: "{,*/}*.{png,jpg,jpeg,gif}"
          dest: "<%= yeoman.dist %>/images"
        ]
    svgmin:
      dist:
        files: [
          expand: true
          cwd: "<%= yeoman.app %>/images"
          src: "{,*/}*.svg"
          dest: "<%= yeoman.dist %>/images"
        ]
    htmlmin:
      dist:
        options:
          collapseWhitespace: true
          collapseBooleanAttributes: true
          removeCommentsFromCDATA: true
          removeOptionalTags: true
        files: [
          expand: true
          cwd: "<%= yeoman.dist %>"
          src: [
            "*.html"
            "views/{,*/}*.html"
          ]
          dest: "<%= yeoman.dist %>"
        ]
    # Allow the use of non-minsafe AngularJS files. Automatically makes it
    # minsafe compatible so Uglify does not destroy the ng references
    ngmin:
      dist:
        files: [
          expand: true
          cwd: ".tmp/concat/scripts"
          src: "*.js"
          dest: ".tmp/concat/scripts"
        ]
    # Replace Google CDN references
    cdnify:
      dist:
        html: ["<%= yeoman.dist %>/*.html"]
    # Copies remaining files to places other tasks can use
    copy:
      dist:
        files: [
          {
            expand: true
            cwd: ".tmp"
            src: "**"
            dest: "<%= yeoman.dist %>"
          }
          {
            expand: true
            cwd: "<%= yeoman.app %>/"
            src: "{,**/}*.{html,css,js}"
            dest: "<%= yeoman.dist %>/"
          }
          {
            expand: true
            cwd: "<%= yeoman.app %>/"
            src: "images/**"
            dest: "<%= yeoman.dist %>/"
          }
          {
            expand: true
            cwd: "<%= yeoman.app %>/"
            src: "bower_components/**"
            dest: "<%= yeoman.dist %>/"
          }
          {
            expand: true
            cwd: "<%= yeoman.app %>/"
            src: "res/**"
            dest: "<%= yeoman.dist %>/"
          }
          {
            expand: true
            cwd: "<%= yeoman.app %>/"
            src: "scripts/l10n/*.json"
            dest: "phonegap/platforms/ios/www"
          }
          {
            expand: true
            cwd: "<%= yeoman.dist %>/"
            src: "**"
            dest: "www"
          }
        ]
    # Run some tasks in parallel to speed up the build process
    concurrent:
      server: [
        "coffee:dist"
        "less"
        "jade"
      ]
      dist: [
        "coffee"
        "less"
        "jade"
      ]
    # By default, your `index.html`'s <!-- Usemin block --> will take care of
    # minification. These next options are pre-configured if you do not wish
    # to use the Usemin blocks.
    cssmin:
      dist:
        files:
          "<%= yeoman.dist %>/styles/main.css": [
            ".tmp/styles/{,*/}*.css"
            "<%= yeoman.app %>/styles/{,*/}*.css"
          ]
    # uglify: {
    #   dist: {
    #     files: {
    #       '<%= yeoman.dist %>/scripts/scripts.js': [
    #         '<%= yeoman.dist %>/scripts/scripts.js'
    #       ]
    #     }
    #   }
    # },
    # concat: {
    #   dist: {}
    # },

    # Test settings
    karma:
      unit:
        configFile: "karma.conf.js"
        singleRun: true
  # Register tasks for all Cordova commands, but namespace
  # the cordova:build since we already have a build task.
  _.functions(cordova).forEach (name) ->
    name = (if (name is "build") then "cordova:build" else name)
    grunt.registerTask name, ->
      @args.unshift name.replace("cordova:", "")
      # Handle URL's being split up by Grunt because of `:` characters
      @args = @args.slice(0, -2).concat(_.last(@args, 2).join(":"))  if _.contains(@args, "http") or _.contains(@args, "https")
      done = @async()
      cmd = path.resolve("./node_modules/cordova/bin", "cordova")
      child = spawn(cmd, @args)
      child.stdout.on "data", (data) ->
        grunt.log.writeln data
        return
      child.stderr.on "data", (data) ->
        grunt.log.error data
        return
      child.on "close", (code) ->
        code = (if (name is "cordova:build") then true else (if code then false else true))
        done code
        return
      return
    return
  # Since Apache Ripple serves assets directly out of their respective platform
  # directories, we watch all registered files and then copy all un-built assets
  # over to www/. Last step is running ordova prepare so we can refresh the ripple
  # browser tab to see the changes.
  grunt.registerTask "ripple", [
    "copy:dist"
    "prepare"
    "ripple-emulator"
  ]
  grunt.registerTask "ripple-emulator", ->
    grunt.config.set "watch",
      all:
        files: _.flatten(_.pluck(grunt.config.get("watch"), "files"))
        tasks: [
          "copy:dist"
          "prepare"
        ]

    cmd = path.resolve("./node_modules/ripple-emulator/bin", "ripple")
    child = spawn(cmd, ["emulate"])
    child.stdout.on "data", (data) ->
      grunt.log.writeln data
      return

    child.stderr.on "data", (data) ->
      grunt.log.error data
      return

    process.on "exit", (code) ->
      child.kill "SIGINT"
      process.exit code
      return
    grunt.task.run ["watch"]
  # Dynamically configure `karma` target of `watch` task so that
  # we don't have to run the karma test server as part of `grunt serve`
  grunt.registerTask "watch:karma", ->
    karma =
      files: [
        "<%= yeoman.app %>/<%= yeoman.scripts %>/**/*.js"
        "test/spec/**/*.js"
      ]
      tasks: [
        "newer:jshint:test"
        "karma:unit:run"
      ]
    grunt.config.set "watch", karma
    grunt.task.run ["watch"]
  grunt.registerTask "serve", (target) ->
    if target is "dist"
      return grunt.task.run([
        "build"
        "connect:dist:keepalive"
      ])
    grunt.task.run [
      "clean:server"
      #'bower-install',
      "concurrent:server"
      "concat"
      "autoprefixer"
      "copy:dist"
      "connect:livereload"
      "watch"
    ]
    return
  grunt.registerTask "test", [
    "clean:server"
    "concurrent:test"
    "autoprefixer"
    "karma:unit:start"
    "watch:karma"
  ]
  grunt.registerTask "build", [
    "clean:dist"
    #'bower-install',
    "useminPrepare"
    "concurrent:dist"
    "autoprefixer"
    "concat"
    #'ngmin',
    "copy:dist"
    "cssmin"
    #'uglify',
    "usemin"
    "htmlmin"
    "cordova:build"
  ]
  grunt.registerTask "cordova", [
    "copy:dist"
    "cordova:build"
  ]
  grunt.registerTask "coverage", [
    "karma:continuous"
    "connect:coverage:keepalive"
  ]
  grunt.registerTask "default", [
    "newer:jshint"
    "karma:continuous"
    "build"
  ]
  return
