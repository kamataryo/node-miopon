gulp      = require 'gulp'
plumber   = require 'gulp-plumber'
coffee    = require 'gulp-coffee'
mocha     = require 'gulp-mocha'
# webserver = require 'gulp-webserver'

gulp.task 'coffee', ->
    gulp.src 'coffee/*.coffee'
        .pipe plumber()
        .pipe coffee {
            bare: false
        }
        .pipe gulp.dest './'


# gulp.task 'webserver', ->
#   gulp.src './'
#     .pipe webserver {
#       livereload: true,
#       directoryListing: true,
#       open: true
#     }


gulp.task 'mocha', ->
    gulp.src 'mocha/miopon.mocha.coffee'
        .pipe mocha {
            compilers: 'coffee-script'
            reporter: 'nyan'
        }


gulp.task 'watch', ->
    gulp.watch [
        'coffee/*.coffee'
        'mocha/*.coffee'
    ]
    , [
        'coffee'
        'mocha'
    ]


gulp.task 'default', [
    'coffee'
    'mocha'
    'watch'
]
