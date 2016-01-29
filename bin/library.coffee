# settings
CONF_FILE_NAME = '.node-miopon'
CONF_PATH = (process.env.HOME || process.env.USERPROFILE) + '/' + CONF_FILE_NAME

# modules requirement
fs = require 'fs'
miopon = require '../index'
coupon = new miopon.Coupon()
querify = miopon.utility.querify

#exportsするもの
e = {}

e.init = ({mioID, mioPass, client_id, redirect_uri}) ->
    #引数がない場合対話的に設定ファイルを作成し、アクセストークンを取得
    return

e.update = ->
    return

e.version = ->
    # npmとして分離した時に書き換え
    pkg = require '../package.json'
    message = "depends on #{pkg.name}@#{pkg.version}"
    console.log message
    return message

e.on = ->
    return

e.off = ->
    return


synonyms =
    init: ['i']
    update: ['auth']
    version: ['v', 'ver']

for method in Object.keys synonyms
    for synonym in synonyms[method]
        if method in Object.keys e
            e[synonym] = e[method]

module.exports = e
return




delay = if process.argv[3] then (process.argv[3] / 1000) else 0
data = ''

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
