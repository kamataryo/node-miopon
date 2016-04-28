nock = require 'nock'


nock 'http://google.com'
    .get '/'
    .reply 200, {
        test:'test'
    }





require('request') {
    url: 'http://google.com/'
    method: 'GET'
}
, (err, res, body)->
    if res
        if res.statusCode is 200
            console.log 'success'
            console.log body
        else
            console.log 'failure'
    else
        console.log 'network error'
