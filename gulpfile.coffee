"use strict"

gulp        =    require "gulp"
$           = do require "gulp-load-plugins"
del         =    require "del"
browserSync =    require "browser-sync"
minimist    =    require "minimist"

argv = minimist process.argv.slice(2),
  alias:
    n: "noyoutube"
  boolean: "noyoutube"
  default:
    noyoutube: false

gulp.task "generate", ["clean","generate:html", "generate:coffee", "generate:scss"]

gulp.task "generate:html", ["markdown"], ->
  gulp.src [
    './src/html/header.html'
    './tmp/index.html'
    './src/html/footer.html'
  ]
    .pipe $.concat "index.html"
    .pipe gulp.dest "./docs"

gulp.task "generate:coffee", ->
  gulp.src "src/coffee/*.coffee"
    .pipe do $.coffee
    .pipe $.concat "script.js"
    .pipe gulp.dest "docs/js/"

gulp.task "generate:scss", ->
  gulp.src "src/scss/*.scss"
    .pipe do $.sass
    .pipe $.concat "style.css"
    .pipe gulp.dest "docs/css/"

gulp.task "markdown", ["youtube"], ->
  gulp.src "./tmp/*.md"
    .pipe do $.markdown
    .pipe gulp.dest "./tmp"

gulp.task "youtube", ->
  iframe = if argv.noyoutube then "" else '<iframe src="https://www.youtube.com/embed/$1"
      frameborder="0" allowfullscreen></iframe>'
  gulp.src "./*.md"
    .pipe $.replace /\[YouTube\]\(\/\/youtu\.be\/([\w-]+)\)/g,
      '\n<div class="youtube">' +
      iframe +
      '</div>\n'
    .pipe gulp.dest "./tmp"

gulp.task "clean", ->
  del.sync "docs/*"


gulp.task "reload", ->
  do browserSync.reload

gulp.task "generate:development", ["generate"], ->
  browserSync
    server:
      baseDir: "docs"
    port: 8082
  
  gulp.watch "docs/**/*", "reload"
  gulp.watch ["./*.md", "./src/html/*.html"], "generate:html"
  gulp.watch "./src/coffee*.coffee", "generate:coffee"
  gulp.watch "./src/scss/*.scss", "generate:scss"