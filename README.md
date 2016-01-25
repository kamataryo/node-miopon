# node-miopon

[<img src="icon.png" width="60" alt="アイコン">](https://www.npmjs.com/package/node-miopon
)

[![Build Status](https://travis-ci.org/KamataRyo/node-miopon.svg?branch=master)](https://travis-ci.org/KamataRyo/node-miopon)
[![npm version](https://badge.fury.io/js/node-miopon.svg)](https://badge.fury.io/js/node-miopon)
![dependencies](https://david-dm.org/kamataryo/node-miopon.svg)
[![Code Climate](https://codeclimate.com/github/KamataRyo/node-miopon/badges/gpa.svg)](https://codeclimate.com/github/KamataRyo/node-miopon)

[IIJmioクーポンスイッチAPI](https://www.iijmio.jp/hdd/coupon/mioponapi.jsp)のNodejs ラッパーです。
oAuthとAPIへのアクセスをラップしています。

実行にはデベロッパーIDとリダイレクトURIの指定が必要です。これらは公式サイトに従って登録してください。
[IIJmioクーポンスイッチAPIのご利用に当たって(IIJmio)](https://www.iijmio.jp/hdd/coupon/mioponapi.jsp#goriyou)


## install
`npm install node-miopon`

## APIs
node-mioponモジュールは、コンストラクタ関数Couponとコンテナオブジェクトutilityをメンバに持ちます。

### coupon.oAuth
phantomjsでoAuthのやり取りを自動化します。
- `coupon.oAuth` takes `{ mioID, mioPass, client_id, redirect_uri, success, failure }`.
- callback `success` will be called with `{client_id, access_token, expires_in}`.
- callback `failure`  will be called with a `error object`.

### coupon.inform
回線の情報（ID、電話番号、クーポンを使用中か、etc.）を取得します。
- `coupon.inform` takes `{client_id, access_token, success, failure}`.
- callback `success` will be called with `{information}`.
- callback `failure`  will be called with a `error object`.

### coupon.turn
クーポンの切り替えをします。
- `coupon.turn` takes `{client_id, access_token, query, success, failure}`.
- callback `success` will be called with no argument.
- callback `failure`  will be called with a `error object`.

### utility.querify
informメソッドで得られたinformationオブジェクトを、turnメソッドで用いるqueryオブジェクトに整形します。
- `utility.querify` takes `{information, couponUse, filter}` and returns `query` synchronously.
- optional `couponUse` accepts..
    + `'on'` or something to be evaluated as `true`
    + `'off'` or something to be evaluated as `false`
- optional `filter` accepts array or string of phone number(s) and filter query if provided. If not, all of the information will be querified.


## example
CoffeeScriptでの例

### oAuthでaccess_tokenを取得
    coupon = new require('node-miopon').Coupon

    coupon.oAuth {
        mioID:     'aaaaaaaa'
        mioPass:   'bbbbbbbb'
        client_id: 'cccccccc' # デベロッパーID
        redirect_uri: 'ddddd'

        success: ({access_token})->
            console.log 'authorized!'

        failure: (err) ->
            console.log 'not authorized..'
            console.log err
    }


### 電話番号'09000000000'のクーポンをオンにする
    coupon = new require('node-miopon').Coupon

    client_id    = 'xxxxxxxxxxxxxxxxxxx'
    access_token = 'yyyyyyyyyyyyyyyyyyy'

    # この例では、最初に全ての回線情報を取得している
    coupon.inform {
        client_id
        access_token

        success: ({information}) ->
            # informationオブジェクトを整形
            query = miopon.utility.querify {
                information
                couponUse: 'on'
                filter: '09000000000'
            }

            # このクエリでturnメソッドを実行
            coupon.turn {
                client_id
                access_token
                query

                success: ->
                    console.log 'turn success!'

                failure: (err) ->
                    console.log err
            }
    }


### 適当なCLIツール（タイマー付き）
`mio on 900 # 15分後にon`
`mio off    # ただちにoff`

#### mio
    #!/bin/bash
    # パスをとおしておく
    coffee path/to/myscript.coffee `echo $1` `echo $2`

#### myscript.coffee
    fs = require 'fs'
    coupon = new require('node-miopon').Coupon()
    querify = miopon.utility.querify

    # 設定ファイル。以下の文字列メンバを持つJSON形式。
    # {mioID, mioPass, client_id, redirect_uri, access_token}
    CONF_PATH = 'path/to/config_file'

    # 引数を展開
    usage = if process.argv[2] is 'on' then true else false
    delay = if process.argv[3] then (process.argv[3] / 1000) else 0
    data = ''

    # 設定ファイル読み込み
    fs.createReadStream CONF_PATH
        .on 'error', (err) ->
            if err.code is 'ENOENT'
                console.log 'config file not found.'
        .on 'data', (chunk) ->
            data += chunk
        .on 'end', () ->
            config = JSON.parse data

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

                        # 契約している回線の情報全ての取得に成功
                        coupon.turn {
                            client_id
                            access_token
                            query: querify {
                                # リクエストとして投げられる形に整形
                                information
                                couponUse: usage
                            }
                            success: ->
                                console.log 'coupon turn successed!'
                            failure: ->
                                console.log 'coupon turn failed..'
                        }

                    failure: (err, res) ->
                        unless res
                            console.log '多分アクセス回数多すぎ'
                            return

                        # 多分access_token期限切れ
                        # 再度oAuthを通す
                        coupon.oAuth {
                            mioID
                            mioPass
                            client_id
                            redirect_uri
                            success: (result)->

                                # oAuth成功
                                access_token = result.access_token
                                config.access_token = access_token

                                # 設定ファイルに書き込み
                                ws = fs.createWriteStream CONF_PATH
                                ws.write JSON.stringify config
                                ws.end()

                                # 新しいaccess_tokenで再度トライ
                                coupon.inform {
                                    client_id
                                    access_token
                                    success: ({information})->
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
                                }
                        }
                    }
        , delay
