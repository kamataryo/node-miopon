# node-miopon

[<img src="icon/icon.png" width="60" alt="アイコン">](https://www.npmjs.com/package/node-miopon
)

[![Build Status](https://travis-ci.org/KamataRyo/node-miopon.svg?branch=master)](https://travis-ci.org/KamataRyo/node-miopon)
[![npm version](https://badge.fury.io/js/node-miopon.svg)](https://badge.fury.io/js/node-miopon)
[![Dependency Status](https://david-dm.org/kamataryo/node-miopon.svg)](https://david-dm.org/kamataryo/node-miopon)
[![devDependency Status](https://david-dm.org/kamataryo/node-miopon/dev-status.svg)](https://david-dm.org/kamataryo/node-miopon#info=devDependencies)

[IIJmioクーポンスイッチAPI](https://www.iijmio.jp/hdd/coupon/mioponapi.jsp)のNode.jsラッパーです。
oAuthとAPIへのアクセスをラップしています。

実行にはデベロッパーIDとリダイレクトURIの指定が必要です。これらは公式サイトに従って登録してください。
[IIJmioクーポンスイッチAPIのご利用に当たって(IIJmioのサイト)](https://www.iijmio.jp/hdd/coupon/mioponapi.jsp#goriyou)


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

    # この例では、最初に全ての回線情報を取得しています
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
