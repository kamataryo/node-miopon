expect = require('chai').expect
_      = require 'underscore'
miopon = require '../node-miopon'


describe 'The `Coupon` constructor, \n', ->
    Coupon = null
    before ->
        Coupon = miopon.Coupon

    it 'should exist.', ->
        expect(Coupon).to.be.a.instanceof Function


    describe 'Test for the instance of `Coupon`. \n', ->
        coupon = null
        before ->
            coupon = new Coupon()

        it 'the instance coupon should have a method `oAuth`', ->
            expect(coupon.oAuth).is.a 'function'

        it 'the instance coupon should have a method `inform`', ->
            expect(coupon.inform).is.a 'function'

        it 'the instance coupon should have a method `turn`', ->
            expect(coupon.turn).is.a 'function'

        it 'the instance coupon should have a string property `api.urls.oAuth`', ->
            expect(coupon.urls.oAuth).to.be.an 'string'

        it 'the instance coupon should have a string property `api.urls.coupon`', ->
            expect(coupon.urls.coupon).to.be.an 'string'


        describe 'oAuth fails wihout mioID, mioPass, client_id or redirect_uri:', ->
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
                {mioID, mioPass, client_id, redirect_uri}
            ]
            _.each args, (arg) ->
                it arg.toString(), (done) ->
                    arg.failure = -> done()
                    coupon.inform arg


        describe 'inform fails wihout access_token or client_id:', ->
            access_token = 'aaaa'
            client_id = 'bbb'
            args = [
                {}
                {access_token}
                {client_id}
            ]
            _.each args, (arg) ->
                it arg.toString(), (done) ->
                    arg.failure = -> done()
                    coupon.inform arg


        describe 'turn fails wihout access_token, client_id or query:', ->
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
                    arg.failure = -> done()
                    coupon.turn arg


describe 'The module `utility`, \n', ->
    utility = null
    before ->
        utility = miopon.utility

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



        describe '`callback`', ->

            it 'the utility has a method `callback`', ->
                expect(utility.callback).is.a 'function'

            it '`callback` call the 1st argument if function', ->
                func = (arg) -> arg + arg
                actual = utility.callback func, 'aaaa'
                expect(actual is 'aaaaaaaa').to.be.true

            it '`callback` also works asynchronously', (done) ->
                utility.callback setTimeout,done,20

            it '`callback` do nothing with the 1st argument if non-function', ->
                actual = utility.callback 'aaa', 'bbb'
                expect(actual).to.be.false
