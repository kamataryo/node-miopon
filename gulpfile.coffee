gulp    = require 'gulp'
plumber = require 'gulp-plumber'
coffee  = require 'gulp-coffee'
header  = require 'gulp-header'
chmod   = require 'gulp-chmod'
mocha   = require 'gulp-mocha'

# build
gulp.task 'coffee', ->
    gulp.src './index.coffee'
        .pipe plumber()
        .pipe coffee {
            bare: false
        }
        .pipe gulp.dest './'

gulp.task 'bin-coffee', ->
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
    'bin-coffee'
]

# test
gulp.task 'test',['build'], ->
    gulp.src [
        './test/index.mocha.coffee'
        './test/mio.mocha.coffee'
    ]
        .pipe mocha {
            compilers: 'coffee-script'
            reporter: 'nyan'
        }

gulp.task 'watch', ->
    gulp.watch [
        './index.coffee'
        './test/*.coffee'
        './test/cases/*.json'
    ]
    , [
        'build'
        'test'
    ]

gulp.task 'default', [
    'build'
    'test'
    'watch'
]
