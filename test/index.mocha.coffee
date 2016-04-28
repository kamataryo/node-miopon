expect = require('chai').expect
nock   = require 'nock'
_      = require 'underscore'
main   = '../' + require('../package.json').main
miopon = require main
oAuth  = miopon.oAuth
Coupon = miopon.Coupon
utility = miopon.utility

alsoTestWebCases = false
describeWebCases = if alsoTestWebCases then describe else describe.skip

# describe 'test of nock', ->
#     it 'test of test', (done)->
#         this.timeout 50000
#         mioID = 'aaaa'
#         mioPass = 'bbb'
#         client_id = 'ccc'
#         redirect_uri = 'ddd'
#         scope = nock miopon.endpoints.oAuth
#         oAuth {
#             mioID
#             mioPass
#             client_id
#             redirect_uri
#             success: ->
#                 console.log 'success'
#                 done()
#             failure: ->
#                 console.log 'failure'
#                 done()
#         }
#
# return



describe 'The `oAuth` function', ->

    it '`oAuth` exists', ->
        expect(oAuth).is.a 'function'

        describeWebCases 'oAuth fails wihout mioID, mioPass, client_id or redirect_uri:', ->
            mioID = 'aaaa'
            mioPass = 'bbb'
            client_id = 'ccc'
            redirect_uri = 'ddd'
            args = [
                {}
                {mioID}, {mioPass}, {client_id}, {redirect_uri}
                {mioID, mioPass}, {mioID, client_id}, {mioID, redirect_uri}
                {mioPass, client_id}, {mioPass, redirect_uri}
                {client_id, redirect_uri}
                {mioID, mioPass, client_id}
                {mioID, mioPass, redirect_uri}
                {mioID, client_id, redirect_uri}
                {mioPass, client_id, redirect_uri}
            ]
            _.each args, (arg) ->
                it arg.toString(), (done) ->
                    arg.failure = ->
                        done()
                    arg.success = ->
                        expect(false).to.be.true
                        done()
                    oAuth arg

            it 'oAuth even failes with a nonsense set of arguments', (done) ->
                this.timeout 50000
                oAuth {
                    mioID
                    mioPass
                    client_id
                    redirect_uri
                    success: ->
                        expect(false).to.be.true
                        done()
                    failure: ->
                        done()
                }


describe 'The `Coupon` constructor, \n', ->

    it 'should exist.', ->
        expect(Coupon).to.be.a.instanceof Function

    describe 'Test for the instance of `Coupon`. \n', ->
        coupon = null
        before ->
            coupon = new Coupon()

        # 後方互換のため残す。v2よりoAuthはCouponコンンストラクタ関数から分離した
        it 'the instance coupon should have a method `oAuth`', ->
            expect(coupon.oAuth).is.a 'function'
        # 互換チェック
        it '`coupon.oAuth` referes miopon.oAuth', ->
            expect(coupon.oAuth).to.equal miopon.oAuth

        it 'the instance coupon should have a method `inform`', ->
            expect(coupon.inform).is.a 'function'

        it 'the instance coupon should have a method `turn`', ->
            expect(coupon.turn).is.a 'function'

        # 後方互換のため残す。v2よりoAuthはCouponコンンストラクタ関数からprivateメンバへ移動
        it 'the instance coupon should have a string property `api.urls.oAuth`', ->
            expect(coupon.urls.oAuth).to.be.an 'string'

        # 後方互換のため残す。v2よりoAuthはCouponコンンストラクタ関数からprivateメンバへ移動
        it 'the instance coupon should have a string property `api.urls.coupon`', ->
            expect(coupon.urls.coupon).to.be.an 'string'


        describeWebCases 'inform fails wihout access_token or client_id:', ->
            access_token = 'aaaa'
            client_id = 'bbb'
            args = [
                {}
                {access_token}
                {client_id}
            ]
            _.each args, (arg) ->
                it arg.toString(), (done) ->
                    arg.failure = ->
                        done()
                    arg.success = ->
                        expect(false).to.be.true
                        done()
                    coupon.inform arg

            it 'inform even fails with nonsense access_token and client_id.', (done) ->
                this.timeout 20000
                coupon.inform {
                    client_id
                    access_token
                    failure: ->
                        done()
                    success: ->
                        expect(false).to.be.true
                        done()
                }


        describeWebCases 'turn fails wihout access_token, client_id or query:', ->
            access_token = 'aaaa'
            client_id = 'bbb'
            query = {query:''}
            args = [
                {}
                {access_token}
                {client_id}
                {access_token, client_id}
                {client_id, query}
                {query, access_token}
            ]
            _.each args, (arg) ->
                it arg.toString(), (done) ->
                    arg.failure = ->
                        done()
                    arg.success = ->
                        expect(false).to.be.true
                        done()
                    coupon.turn arg

            it 'turn even fails with nonsense access_token, client_id and query.', (done) ->
                this.timeout 20000
                coupon.turn {
                    client_id
                    access_token
                    query
                    failure: ->
                        done()
                    success: ->
                        expect(false).to.be.true
                        done()
                }


describe 'The module `utility`, \n', ->

    it 'should exist.', ->
        expect(utility).to.be.a.instanceof Object


    describe 'Test for the each member of `utility`. \n', ->


        describe '`arraify`', ->

            it 'the utility has a method `arraify`', ->
                expect(utility.arraify).is.a 'function'


                describe 'test of the utility method `arraify` cases: ', ->

                    it 'undefined', ->
                        result = utility.arraify undefined
                        correctAnswer = []
                        expect(result).to.eql correctAnswer
                    it 'string.', ->
                        result = utility.arraify '1234567890'
                        correctAnswer = ['1234567890']
                        expect(result).to.eql correctAnswer

                    it 'number.', ->
                        result = utility.arraify 1234567890
                        correctAnswer = ['1234567890']
                        expect(result).to.eql correctAnswer

                    it 'string with hyphen to be ignored.', ->
                        result = utility.arraify '1-23-4567-89-0'
                        correctAnswer = ['1234567890']
                        expect(result).to.eql correctAnswer

                    it 'string with brackets to be ignored.', ->
                        result = utility.arraify '1(2)3{45}67[890]'
                        correctAnswer = ['1234567890']
                        expect(result).to.eql correctAnswer

                    it 'string with alphabets to be ignored.', ->
                        result = utility.arraify '1a2b3c4d5e6f7g8h9i0'
                        correctAnswer = ['1234567890']
                        expect(result).to.eql correctAnswer

                    it 'non-number', ->
                        result = utility.arraify 'aaa'
                        correctAnswer = []
                        expect(result).to.eql correctAnswer

                    it 'non-number and number', ->
                        result = utility.arraify ['','1234567890','^&(*&&^())']
                        correctAnswer = ['1234567890']
                        expect(result).to.eql correctAnswer

                    it 'non-numbers', ->
                        result = utility.arraify ['','aaa','^&(*&&^())']
                        correctAnswer = []
                        expect(result).to.eql correctAnswer

                    it 'array case', ->
                        args = [
                            '1234567890'
                            1234567890
                            '1-23-4567-89-0'
                            '1(2)3{45}67[890]'
                            '1a2b3c4d5e6f7g8h9i0'
                        ]
                        result = utility.arraify args
                        correctAnswer = ('1234567890' for n in args)
                        expect(result).to.eql correctAnswer


        describe '`orderCouponUse`', ->

            it 'the utility has a method `orderCouponUse`', ->
                expect(utility.orderCouponUse).is.a 'function'


                describe 'test of the utility method `orderCouponUse` cases: ', ->

                    _.each ['on', 1, 'abc', true], (arg) ->
                        it '`orderCouponUse` works well in positive cases("on" or something evaluated as true)', ->
                            result = utility.orderCouponUse arg
                            expect(result).to.true

                    _.each ['off', 0, '', false], (arg) ->
                        it '`orderCouponUse` works well in negative cases("off" or something evaluated as false)', ->
                            result = utility.orderCouponUse arg
                            expect(result).to.false


        describe '`querify`', ->

            it 'the utility has a method `querify`', ->
                expect(utility.querify).is.a 'function'


                describe 'test of the utility method `querify` cases: ', ->


                    describe 'case of information object: ', ->

                        it '`querify` works well', ->
                            result = utility.querify {
                                information: require '../test/cases/querify-before.json'
                            }
                            correct =require '../test/cases/querify-after.json'
                            expect(result).to.eql correct

                        it '`querify` works well with filter', ->
                            result = utility.querify {
                                information: require '../test/cases/querify-before.json'
                                filter: ['2345678901','4567890123']
                            }
                            correct =require '../test/cases/querify-after_filtered.json'
                            expect(result).to.eql correct

                        it '`querify` works well with coupon order1', ->
                            result = utility.querify {
                                information: require '../test/cases/querify-before.json'
                                couponUse: true
                            }
                            correct =require '../test/cases/querify-after_ordered1.json'
                            expect(result).to.eql correct

                        it '`querify` works well with coupon order2', ->
                            result = utility.querify {
                                information: require '../test/cases/querify-before.json'
                                couponUse: 'off'
                            }
                            correct =require '../test/cases/querify-after_ordered2.json'
                            expect(result).to.eql correct

                        it '`querify` works well with broken input', ->
                            result = utility.querify {
                                information: require '../test/cases/querify-before_broken.json'
                            }
                            correct =require '../test/cases/querify-after_broken.json'
                            expect(result).to.eql correct


        describe '`generateQuery`', ->

            it 'the utility has a method `generateQuery`', ->
                expect(utility.generateQuery).is.a 'function'


            describe 'behaviors:', ->


                it 'works with no codes', ->
                    turnStates = []
                    exact = couponInfo: []
                    expect(utility.generateQuery {turnStates}).to.eql exact

                describe 'works with unformatted codes will be eliminated:', ->
                    turnStatesCases = [
                        null, undefined,'dummycode', 1, false, true, {}, []
                        [null], [undefined],['dummycode'], [1], [false], [true], {}, []
                    ]
                    exact = couponInfo: []
                    _.each turnStatesCases, (turnStateCase) ->
                        it "#{turnStateCase}", ->
                            expect(utility.generateQuery {turnStates:turnStateCase}).to.eql exact


                it 'works with single code', ->
                    turnStates = [
                        {
                            'hdoWWWWWWWW':true
                        }
                    ]
                    exact =
                        couponInfo: [
                            {
                                hdoInfo: [
                                    {hdoServiceCode: 'hdoWWWWWWWW', couponUse: true }
                                ]
                            }
                        ]
                    expect(utility.generateQuery {turnStates}).to.eql exact

                it 'works with single code and "on" statement', ->
                    turnStates = [
                        {
                            'hdoWWWWWWWW':'on'
                        }
                    ]
                    exact =
                        couponInfo: [
                            {
                                hdoInfo: [
                                    {hdoServiceCode: 'hdoWWWWWWWW', couponUse: true }
                                ]
                            }
                        ]
                    expect(utility.generateQuery {turnStates}).to.eql exact

                it 'works with single code and "off" statement', ->
                    turnStates = [
                        {
                            'hdoWWWWWWWW':'off'
                        }
                    ]
                    exact =
                        couponInfo: [
                            {
                                hdoInfo: [
                                    {hdoServiceCode: 'hdoWWWWWWWW', couponUse: false }
                                ]
                            }
                        ]
                    expect(utility.generateQuery {turnStates}).to.eql exact

                it 'works with several code', ->
                    turnStates = [
                        {
                            'hdoWWWWWWWW':true
                            'hdoYYYYYYYY':false
                            'hdoZZZZZZZZ':true
                        }
                    ]
                    exact =
                        couponInfo: [
                            {
                                hdoInfo: [
                                    {hdoServiceCode: 'hdoWWWWWWWW', couponUse: true }
                                    {hdoServiceCode: 'hdoYYYYYYYY', couponUse: false }
                                    {hdoServiceCode: 'hdoZZZZZZZZ', couponUse: true }
                                ]
                            }
                        ]
                    expect(utility.generateQuery {turnStates}).to.eql exact


                it 'works with several coupon', ->
                    turnStates = [
                        {
                            'hdoWWWWWWWW':false
                        },
                        {
                            'hdoXXXXXXXX':true
                        }
                    ]
                    exact =
                        couponInfo: [
                            {
                                hdoInfo: [
                                    {hdoServiceCode: 'hdoWWWWWWWW', couponUse: false }
                                ]
                            },
                            {
                                hdoInfo: [
                                    {hdoServiceCode: 'hdoXXXXXXXX', couponUse: true }
                                ]
                            }
                        ]
                    expect(utility.generateQuery {turnStates}).to.eql exact

                it 'works with complex object', ->
                    turnStates = [
                        {
                            'hdoWWWWWWWW':true
                        },
                        {
                            'hdoXXXXXXXX':false
                            'hdoYYYYYYYY':true
                        },
                        {
                            'hdoZZZZZZZZ':false
                            'hdoVVVVVVVV':true
                            'hdoUUUUUUUU':false
                        }
                    ]
                    exact =
                        couponInfo: [
                            {
                                hdoInfo: [
                                    {hdoServiceCode: 'hdoWWWWWWWW', couponUse: true }
                                ]
                            },
                            {
                                hdoInfo: [
                                    {hdoServiceCode: 'hdoXXXXXXXX', couponUse: false }
                                    {hdoServiceCode: 'hdoYYYYYYYY', couponUse: true }
                                ]
                            },
                            {
                                hdoInfo: [
                                    {hdoServiceCode: 'hdoZZZZZZZZ', couponUse: false }
                                    {hdoServiceCode: 'hdoVVVVVVVV', couponUse: true }
                                    {hdoServiceCode: 'hdoUUUUUUUU', couponUse: false }
                                ]
                            }
                        ]
                    expect(utility.generateQuery {turnStates}).to.eql exact


        describe '`callback`', ->

            it 'the utility has a method `callback`', ->
                expect(utility.callback).is.a 'function'

            it '`callback` call the 1st argument if function', ->
                func = (arg) -> arg + arg
                actual = utility.callback func, 'aaaa'
                expect(actual is 'aaaaaaaa').to.be.true

            it '`callback` also works asynchronously', (done) ->
                utility.callback setTimeout, done, 20

            it '`callback` do nothing with the 1st argument if non-function', ->
                actual = utility.callback 'aaa', 'bbb'
                expect(actual).to.be.false
