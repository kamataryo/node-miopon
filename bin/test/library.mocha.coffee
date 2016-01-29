expect = require('chai').expect
_      = require 'underscore'
mio    = require '../library'


describe 'Interdfaces', ->
    methods = [
        ['init']
        ['update','auth']
        ['version','v','ver']
        ['on']
        ['off']
    ]
    _.each _.flatten(methods), (method) ->
        it "#{method} exists.", ->
            expect(mio[method]).to.be.a 'function'

    _.each methods, (synonyms) ->
        _.each synonyms, (method1) ->
            _.each synonyms, (method2) ->
                unless method1 is method2
                    it "#{method1} is synonym of #{method2}", ->
                        expect(mio[method1]).to.equal mio[method2]


describe 'behavior of ..', ->
    it 'version is to exports some message.', ->
        expect(mio['version'].apply()).not.to.equal ''
