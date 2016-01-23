# これは、stream API実装のテスト

inherits = require('util').inherits
Stream = require('stream')
Readable = Stream.Readable
Writable = Stream.Writable
Transform = Stream.Transform

MyReadableStream = (options) ->
    Readable.call this, options

MyWritableStream = (options) ->
    Writable.call this, {objectMode: true}

MyTransformStream = (options) ->
    Transform.call this, options

inherits MyReadableStream, Readable
inherits MyWritableStream, Writable
inherits MyTransformStream, Transform

MyReadableStream.prototype._read = (size) ->
    this.push 'aaa'
    this.push 'bbb'
    this.push null

MyWritableStream.prototype._write = (chunk, encoding, done) ->
    console.log String chunk
    done()


#--------------------------------------



# test writable stream to console log Object pretty
testWritableStream = () ->
    Writable.call this, {objectMode: true}
inherits testWritableStream, Writable
testWritableStream.prototype._write = (chunk, encoding, done) ->
    console.log JSON.stringify chunk, null, 2
    done()

# provide readable stream from JSON source
readableStreamProvider = (source) ->
    this.__source = source
    Readable.call this, {objectMode: true}
inherits readableStreamProvider, Readable
readableStreamProvider.prototype._read = (size) ->
    this.push this.__source
    this.push null



provideToken = (src) ->
    this.__src = src
    Duplex.call this, {objectMode: true}
inherits provideToken, Duplex
provideToken.prototype._write = (chunk, encoding, done) ->
    done()




sc = new readableStreamProvider {
    mioID: ''
    mioPass: ''
    mioDevID: ''
    redirectTo: 'aaa'
}

# sc.pipe (new testWritableStream())


return
#--------------------------------------
# config.createReadStream = ([conig object] || 'path/to/config_file') ->
#
# config.createWriteStream = ([conig object], 'path/to/config_file') ->
#
# config.createDuplexStream = ([conig object], 'path/to/config_file') ->
#
# auth.createTransformStream
#
# token.createReadStream = ([token object] || 'path/to/token_file') ->
#
# token.createWriteStream = ([token object], 'path/to/token_file') ->
#
# token.createDuplexStream = ([token object], 'path/to/token_file') ->
#
# access.createWriteStream


#--------------------------------------


questionConfig = () ->
    Readable.call this

inherits questionConfig, Readable

questionConfig.prototype._read = (size) ->
    that = this
    rl = require('readline').createInterface {
        input: process.stdin,
        output: process.stdout
    }

    rl.question '(mio ID)? ', (mioID) ->
        rl.question '(IIJ password)? ', (mioPass) ->
            rl.question '(IIJ developers ID)? ', (mioDevID) ->
                rl.question '(redirect URI)? ', (redirectTo) ->
                    input =
                        mioID: mioID
                        mioPass: mioPass
                        mioDevID: mioDevID
                        redirectTo: redirectTo
                    that.push JSON.stringify input
                    that.push null
                    rl.close()



mr = new questionConfig()



# [
#     {      mioID: '(mio ID)? ' }
#     {    mioPass: '(IIJ password)? ' }
#     {   mioDevID: '(IIJ developers ID)? ' }
#     { redirectTo: '(redirect URI)? ' }
# ]

# (new questionConfig()).pipe process.stdout


console.log({} instanceof Array)
console.log([] instanceof Object)
console.log('aa'.toString())




__Coupon = () ->



    this.prototype = {

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

        turn: ({client_id, access_token, couponUse, filter, success}) =>
            callback = utility.callback
            unless client_id && access_token
                throw new Error 'no access_token specified'
            request = require 'request'
            filter = this.utility.arraify filter
            this.inform {
                client_id,
                access_token,
                success: (information) ->
                    query = utility.querify {
                        information
                        couponUse
                        filter
                    }
                    request {
                        url: this.urls.endpoint
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
                        else
                            throw new Error "http error: #{res.statusCode}"
            }



    }
