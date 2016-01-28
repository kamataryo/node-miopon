fs = require 'fs'
miopon = require '../index'
coupon = new miopon.Coupon()
querify = miopon.utility.querify
CONF_PATH = (process.env.HOME || process.env.USERPROFILE) + '/.node-miopon.json'
if process.argv[2] is 'on'
    usage = true
else
    usage = false

delay = if process.argv[3] then (process.argv[3] / 1000) else 0
data = ''

console.log 'hello cli'
return

fs.createReadStream CONF_PATH
    .on 'error', (err) ->
        if err.code is 'ENOENT'
            console.log 'config file not found.'
    .on 'data', (chunk) ->
        data += chunk
    .on 'end', () ->
        config = JSON.parse data
        console.log 'config read finished.'

        mioID = config.mioID
        mioPass = config.mioPass
        client_id = config.client_id
        access_token = config.access_token
        redirect_uri = config.redirect_uri

        setTimeout ->
            coupon.inform {
                client_id
                access_token
                success: ({information})->
                    console.log 'coupon information obtained.'
                    coupon.turn {
                        client_id
                        access_token
                        query: querify {
                            information
                            couponUse: usage
                        }
                        success: ->
                            console.log 'coupon turn successed!'
                        failure: ->
                            console.log 'coupon turn failed..'
                    }
                failure: (err) ->
                    console.log err

                failure: (err, res) ->
                    console.log 'coupon information not obtained.'
                    console.log err
                    unless res
                        console.log 'access too many'
                        return
                    coupon.oAuth {
                        mioID
                        mioPass
                        client_id
                        redirect_uri
                        success: (result)->
                            console.log 'oAuth success.'
                            access_token = result.access_token
                            config.access_token = access_token
                            ws = fs.createWriteStream CONF_PATH
                            ws.write JSON.stringify config
                            ws.end()
                            coupon.inform {
                                client_id
                                access_token
                                success: ({information})->
                                    console.log 'coupon information obtained with new access_token.'
                                    coupon.turn {
                                        client_id
                                        access_token
                                        query: querify {
                                            information
                                            couponUse: usage
                                        }
                                    }
                            }
                    }
                }
        , delay
