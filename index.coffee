endpoints =
    oAuth: 'https://api.iijmio.jp/mobile/d/v1/authorization/'
    coupon: 'https://api.iijmio.jp/mobile/d/v1/coupon/'



oAuth = ({mioID, mioPass, client_id, redirect_uri, success, failure}) ->
    callback = utility.callback
    unless mioID && mioPass && client_id && redirect_uri
        callback failure, {Error: 'no oAuth information'}
        return

    querystring  = require 'querystring'
    phantom      = require 'phantom'
    urlUtil      = require 'url'

    csrf_token = require('crypto')
        .randomBytes 10
        .toString 'hex'

    qs = querystring.stringify {
        response_type: 'token'
        client_id: client_id
        redirect_uri: redirect_uri
        state: csrf_token
    }
    url = "#{endpoints.oAuth}?#{qs}"
    phantom.create (ph) ->
        ph.createPage (page) ->
            page.open url, (status) ->
                console.log "page open: #{status}."
                unless status is 'success'
                    callback failure, {Error: 'page open failed'}
                    ph.exit()
                    return
                else
                    # phantomJS sandobox
                    page.evaluate (mioID, mioPass) ->
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
                                hash = urlUtil.parse(url).hash
                                if hash
                                    hash = hash.slice 1
                                    result = querystring.parse(hash)
                                    result.client_id = client_id
                                    access_token = result.access_token
                                    state = result.state
                                    delete result.state
                                    delete result.token_type
                                    if access_token && state is csrf_token
                                            callback success, result
                                    else unless access_token
                                        callback failure, {Error:'error occured, no access token found.'}
                                else
                                    callback failure, {Error:'error occured, no access token found.'}
                                ph.exit()
                        ,4000
                    ,mioID
                    ,mioPass



# define Classes
class Coupon
    'use strict'

    # http request for coupon information
    inform: ({client_id, access_token, success, failure}) =>
        callback = utility.callback
        unless client_id && access_token
            callback failure, new Error 'no access_token specified'
            return
        require('request') {
            url: this.urls.coupon
            method: 'GET'
            headers:
                'X-IIJmio-Developer': client_id
                'X-IIJmio-Authorization': access_token
        }
        , (err, res, body)->
            if res
                if res.statusCode is 200
                    callback success, {information: JSON.parse body}
                else
                    callback failure, err
            else
                callback failure, err, res



    turn: ({client_id, access_token, query, success, failure}) =>
        callback = utility.callback
        unless client_id && access_token
            callback failure, new Error 'no access_token specified'
            return
        unless query
            callback failure, new Error 'no query specified'
            return
        require('request') {
            url: this.urls.coupon
            method: 'PUT'
            headers:
                'X-IIJmio-Developer': client_id
                'X-IIJmio-Authorization': access_token
                'Content-Type': 'application/json'
            json: query
        }
        ,(err, res, body) ->
            if res.statusCode is 200
                callback success
                return
            else
                callback failure, err
                return

    #後方互換のため残す
    oAuth: oAuth
    urls:
        oAuth: endpoints.oAuth #'https://api.iijmio.jp/mobile/d/v1/authorization/'
        coupon: endpoints.coupon #'https://api.iijmio.jp/mobile/d/v1/coupon/'



utility =
    # validate phone numbers. transform it into Array
    arraify: (numbers) ->
        unless numbers? then return []
        _ = require 'underscore'
        results = []
        transform = (value) ->
            result = value.toString().replace /\D/g, ''
            if result isnt '' then results.push result
        # iterate if array
        if Array.isArray numbers then _.each(numbers, transform) else transform(numbers)
        return results

    # validate the order command for couponUse and transform it into Boolean.
    orderCouponUse: (order) ->
        if order is 'on'
             return true
        else if  order is 'off'
            return false
        else
            return Boolean(order)

    # trim reduntdant element from the JSON of info (usually obtain from API(Coupon.inform))
    # Synchronous method
    querify: ({information, couponUse, filter}) =>
        unless information
            throw new Error 'no source option exception'
        _ = require 'underscore'
        couponUse = utility.orderCouponUse couponUse
        filter = utility.arraify filter

        # create clone object after traversing `information` object
        # eliminate parental object without certain property
        # 電話番号フィルタが入力されていない場合は、すべてを通し、入力されていればそれのみを採用する
        result = {couponInfo:[]}
        if Array.isArray information.couponInfo
            _.each information.couponInfo, (hdd) ->
                each_couponInfo = {hdoInfo:[]}
                if Array.isArray hdd.hdoInfo
                    _.each hdd.hdoInfo, (hdo) ->
                        if hdo.hdoServiceCode && (filter.length is 0 || (filter.length > 0 && (hdo.number in filter)))
                            each_couponInfo.hdoInfo.push {
                                hdoServiceCode: hdo.hdoServiceCode
                                couponUse: couponUse
                            }
                    if each_couponInfo.hdoInfo.length > 0 then result.couponInfo.push each_couponInfo
        return result



    # utility function for safe callback
    callback: ->
        args = Array.prototype.slice.call arguments
        if (typeof args[0]) is 'function'
            callback = args.shift()
            callback.apply callback, args
        else
            return false


module.exports = {oAuth,Coupon,utility}
