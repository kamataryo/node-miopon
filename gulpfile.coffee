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
gulp.task 'test',['coffee'], ->
    gulp.src [
        './test/index.mocha.coffee'
    ]
        .pipe mocha {
            compilers: 'coffee-script'
            reporter: 'nyan'
        }

# test
gulp.task 'bin-test',['bin-coffee'], ->
    gulp.src [
        './bin/test/library.mocha.coffee'
    ]
        .pipe mocha {
            compilers: 'coffee-script'
            reporter: 'nyan'
        }


gulp.task 'bin-watch', ->
    gulp.watch [
        './bin/mio.coffee'
        './bin/library.coffee'
        './bin/test/library.mocha.coffee'
    ]
    , [
        'bin-coffee'
        'bin-test'
    ]


gulp.task 'watch', ->
    gulp.watch [
        './index.coffee'
        './bin/mio.coffee'
        './test/index.mocha.coffee'
        './bin/test/mio.mocha.coffee'
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
