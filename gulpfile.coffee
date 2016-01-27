gulp      = require 'gulp'
plumber   = require 'gulp-plumber'
coffee    = require 'gulp-coffee'
header    = require 'gulp-header'
chmod     = require 'gulp-chmod'
mocha     = require 'gulp-mocha'


# build
gulp.task 'coffee', ->
    gulp.src './node-miopon.coffee'
        .pipe plumber()
        .pipe coffee {
            bare: false
        }
        .pipe gulp.dest './'

gulp.task 'cli-coffee', ->
    gulp.src './bin/mio.coffee'
        .pipe plumber()
        .pipe coffee {
            bare: false
        }
        .pipe header '#!/usr/bin/env node\n'
        .pipe chmod 755
        .pipe gulp.dest './bin/'

gulp.task 'build', [
    'coffee'
    'cli-coffee'
]


# test
gulp.task 'mocha',['coffee'], ->
    gulp.src './test/node-miopon.mocha.coffee'
        .pipe mocha {
            compilers: 'coffee-script'
            reporter: 'nyan'
        }


gulp.task 'watch', ->
    gulp.watch [
        './node-miopon.coffee'
        './test/node-miopon.mocha.coffee'
        './test/cases/*.json'
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
