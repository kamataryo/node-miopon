should = require 'should'
miopon = require '../miopon'

describe 'Base constructors existence', ->
    constructorNames = [
        'Coupon'
        'Info'
        'Log'
    ]
    for name in constructorNames
        it "module `miopon` should have a constructor `#{name}` as its member.", ->
            should.exist miopon[name]
            miopon[name].should.instanceof Function
