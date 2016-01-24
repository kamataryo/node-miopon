gulp      = require 'gulp'
plumber   = require 'gulp-plumber'
coffee    = require 'gulp-coffee'
mocha     = require 'gulp-mocha'

gulp.task 'coffee', ->
    gulp.src './node-miopon.coffee'
        .pipe plumber()
        .pipe coffee {
            bare: false
        }
        .pipe gulp.dest './'


gulp.task 'mocha',['coffee'], ->
    gulp.src [
        './test/node-miopon.mocha.coffee'
    ]
        .pipe mocha {
            compilers: 'coffee-script'
            reporter: 'nyan'
        }


gulp.task 'watch', ->
    gulp.watch [
        './node-miopon.coffee'
        './test/*.coffee'
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
