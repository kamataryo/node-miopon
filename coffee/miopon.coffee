# define module
Coupon = () ->
    'use strict'

    fs = require 'fs'
    readline = require 'readline'
    path = require 'path'
    request = require 'request'
    _ = require 'underscore'

    CONF_PATH = (process.env.HOME || process.env.HOMEPATH || process.env.USERPROFILE) + '/.miopon-toggle/conf.json'
    TOKEN_PATH = (process.env.HOME || process.env.HOMEPATH || process.env.USERPROFILE) + '/.miopon-toggle/token.json'
    config = {}
    access_token = ''


    this.prototype = {

        # CUI input(*) of infomation for OAuth
        # callback takes 1 objective argument inputted(*).
        #  obj =
        #   mioID
        #   mioPass
        #   mioDevID
        #   redirectTo
        setConfig: (callback) ->
            rl = readline.createInterface {
                input: process.stdin,
                output: process.stdout
            }

            rl.question '(mio ID)? ', (mioID) ->
                rl.question '(IIJ password)? ', (mioPass) ->
                    rl.question '(IIJ developers ID)? ', (mioDevID) ->
                        rl.question '(redirect URI)? ', (redirectTo) ->
                            rl.close()
                            input =
                                mioID: mioID
                                mioPass: mioPass
                                mioDevID: mioDevID
                                redirectTo: redirectTo
                            ws = fs.createWriteStream CONF_PATH
                                .on 'close', ->
                                    config = input
                                    if (typeof callback) is 'function' then callback input
                            ws.write JSON.stringify input
                            ws.end()


        # read OAuth info from file.
        # cakkabck takes 1 argument of JSON.parsed OAuth info.
        readConfig: (callback) ->
            data = ''
            fs.createReadStream CONF_PATH
                .on 'error', (err) ->
                    if err.code is 'ENOENT'
                        console.log 'config file not found.'
                .on 'data', (chunk) ->
                    data += chunk
                .on 'end', () ->
                    output = JSON.parse data
                    config = output
                    if (typeof callback) is 'function' then callback output


        # implicit grant by phantomJS
        # need to check confirmation of IIJ API
        setAccessToken: (callback) ->
            qsUtil = require 'querystring'
            phantom = require 'phantom'
            urlUtil = require 'url'

            base = 'https://api.iijmio.jp/mobile/d/v1/authorization/'
            myState = 'stateTestment' # checking param for csrf(?)
            qs = qsUtil.stringify {
                response_type: 'token'
                client_id: config.mioDevID
                redirect_uri: config.redirectTo
                state: myState
            }
            url = "#{base}?#{qs}"
            phantom.create (ph) ->
                ph.createPage (page) ->
                    page.open url, (status) ->
                        console.log "page open: #{status}."
                        if status isnt 'success'
                            ph.exit()

                        page.evaluate (mioID, mioPass) ->
                            # in phantomJS sandobox
                            document.getElementById('username').value = mioID
                            document.getElementById('password').value = mioPass
                            document.getElementById('submit').click()
                            # wait for dom change
                            setTimeout ->
                                document.getElementById('confirm').click()
                            ,500
                        , ->
                            # wait for URL rewrite
                            setTimeout ->
                                page.evaluate ->
                                    return document.URL
                                , (url) ->
                                    hash = urlUtil.parse(url).hash.slice 1
                                    access_token = qsUtil.parse(hash)['access_token']
                                    if access_token isnt undefined
                                        ws = fs.createWriteStream TOKEN_PATH
                                            .on 'close', ->
                                                if (typeof callback) is 'function' then callback access_token
                                        ws.write JSON.stringify {
                                            access_token:access_token
                                            devID:config.mioDevID
                                        }
                                        ws.end()

                                        if typeof callback is 'function' then callback access_token
                                    else
                                        console.log 'error occured, no access token found.'
                                        page.render 'test.png'
                                    ph.exit()
                            ,1000
                        ,config.mioID
                        ,config.mioPass


        readAccessToken: (callback) ->
            data = ''
            that = this
            fs.createReadStream TOKEN_PATH
                .on 'error', (err) ->
                    if err.code is 'ENOENT'
                        console.log 'Access token not found.'
                .on 'data', (chunk) ->
                    data += chunk
                .on 'end', () ->
                    tokens = JSON.parse data
                    if (typeof callback) is 'function' then callback tokens


        # getCouponState: (callback) ->
        #     this.readAccessToken (tokens) ->
        #         request {
        #             url: 'https://api.iijmio.jp/mobile/d/v1/coupon/'
        #             method: 'GET'
        #             headers:
        #                 'X-IIJmio-Developer': tokens.mioDevID
        #                 'X-IIJmio-Authorization': tokens.access_token
        #         }
        #         , (err, res, body)->
        #             if res.statusCode is 200
        #                 callback JSON.parse(body)
        #             else
        #                 console.log "http error:#{res.statusCode}"


        # Info: (info) ->
        #     this.prototype.querify = (numbers) ->
        #         if typeof numbers isnt 'array' then numbers = [numbers.toString()]
        #         obj = _.clone this
        #         obj.prototype = null
        #
        #         couponInfo = _.pick obj, 'couponInfo'
        #         _.each couponInfo, _.pick 'hdoInfo'
        #     return this



        # http request for coupon information
        inform: (options, callback) ->
            # check arguments and parse
            unless options.client_id && options.access_token
                console.log 'no token specified.'
                return false
            client_id = options.client_id
            access_token = options.access_token

            request {
                url: this.api.endpoint
                method: 'GET'
                headers:
                    'X-IIJmio-Developer': client_id
                    'X-IIJmio-Authorization': access_token
            }
            , (err, res, body)->
                if !err && res.statusCode is 200
                    information = JSON.parse body
                    if callback && (typeof callback) is 'function'
                        callback(information, client_id, access_token)
                    else
                        return body
                else
                    console.log "http error: #{if res then res.statusCode else err}"



        turn: (options, callback) ->
            unless options.client_id && options.access_token
                console.log 'no token specified.'
                return false
            unless options.couponInfo
                console.log 'no couponInfo object specified.'
                return false
            client_id = options.client_id
            access_token = options.access_token
            couponInfo = options.couponInfo
            request {
                    url: this.api.endpoint
                    method: 'PUT'
                    headers:
                        'X-IIJmio-Developer': client_id
                        'X-IIJmio-Authorization': access_token
                        'Content-Type': 'application/json'
                    json: couponInfo
                }
                ,(err, res, body) ->
                    if res.statusCode is 200
                        console.log body
                        if callback && (typeof callback) is 'function'
                            callback(client_id, access_token)
                        else
                            return body
                    else
                        console.log "http error: #{res.statusCode}"



        api: {
            endpoint: 'https://api.iijmio.jp/mobile/d/v1/coupon/'
        }
        utility: {
            validateNumbers: (numbers) ->
                if numbers
                    if typeof numbers isnt 'array' then numbers = [numbers]
                    numbers = _.map numbers, (number) ->
                        number.toString().replace /\D/g, ''
                else
                    numbers = []
                return numbers

            querify: (options) ->
                unless options.src && options.couponUse
                    console.log 'no token specified.'
                    return false
                numbers = this.util.validateNumbers options.numbers
                src = options.src
                couponUse = options.couponUse

                if couponUse is 'on'
                        couponUse = true
                    else if  couponUse is 'off'
                        couponUse = false
                    else
                        couponUse = Boolean(couponUse)

                result = _.clone src
                result = _.pick result, 'couponInfo'
                result.couponInfo = _.map result.couponInfo, (hddService) ->
                    return _.pick hddService, 'hdoInfo'

                for couponInfo in result.couponInfo
                    for hdoInfo in couponInfo.hdoInfo
                        # 電話番号でフィルタ
                        # if options.numbers
                        #     unless hdoInfo.number in options.numbers

                        for key, value of hdoInfo
                            unless key is 'couponUse' || key is 'hdoServiceCode'
                                delete hdoInfo[key]
                            if key is 'couponUse'
                                hdoInfo[key] = couponUse
                return result
        }
    }

module.exports.Coupon = Coupon




coupon = new Coupon()



console.log coupon.utility.validateNumbers '1-234asdf5[]46'


return
