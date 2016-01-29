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

# test
gulp.task 'mocha',['coffee'], ->
    gulp.src [
        './test/index.mocha.coffee'
    ]
        .pipe mocha {
            compilers: 'coffee-script'
            reporter: 'nyan'
        }


# synonym
gulp.task 'build', ['coffee']
gulp.task 'test', ['mocha']



gulp.task 'watch', ->
    gulp.watch [
        './index.coffee'
        './test/index.mocha.coffee'
        './test/cases/*.json'
    ]
    , ['build','test']

gulp.task 'default', ['build','test','watch']
