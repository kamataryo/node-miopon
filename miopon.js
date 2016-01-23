(function() {
  var Coupon, utility,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  Coupon = (function() {
    'use strict';
    function Coupon() {
      this.turn = bind(this.turn, this);
      this.inform = bind(this.inform, this);
    }

    Coupon.prototype.oAuth = function(arg) {
      var callback, client_id, csrf_token, failure, mioID, mioPass, phantom, qs, qsUtil, redirect_uri, success, url, urlUtil;
      mioID = arg.mioID, mioPass = arg.mioPass, client_id = arg.client_id, redirect_uri = arg.redirect_uri, success = arg.success, failure = arg.failure;
      callback = utility.callback;
      if (!(mioID && mioPass && client_id && redirect_uri)) {
        callback(failure, {
          Error: 'no oAuth information'
        });
        return;
      }
      qsUtil = require('querystring');
      phantom = require('phantom');
      urlUtil = require('url');
      csrf_token = require('crypto').randomBytes(10).toString('hex');
      qs = qsUtil.stringify({
        response_type: 'token',
        client_id: client_id,
        redirect_uri: redirect_uri,
        state: csrf_token
      });
      url = this.urls.oAuth + "?" + qs;
      return phantom.create(function(ph) {
        return ph.createPage(function(page) {
          return page.open(url, function(status) {
            console.log("page open: " + status + ".");
            if (status !== 'success') {
              callback(failure, {
                Error: 'page open failed'
              });
              return ph.exit();
            } else {
              return page.evaluate(function(mioID, mioPass) {
                document.getElementById('username').value = mioID;
                document.getElementById('password').value = mioPass;
                document.getElementById('submit').click();
                return setTimeout(function() {
                  return document.getElementById('confirm').click();
                }, 500);
              }, function() {
                return setTimeout(function() {
                  return page.evaluate(function() {
                    return document.URL;
                  }, function(url) {
                    var access_token, hash, result, state;
                    hash = urlUtil.parse(url).hash;
                    if (hash) {
                      hash = hash.slice(1);
                      result = qsUtil.parse(hash);
                      result.client_id = client_id;
                      access_token = result.access_token;
                      state = result.state;
                      delete result.state;
                      delete result.token_type;
                      if (access_token && state === csrf_token) {
                        callback(success, result);
                      } else if (!access_token) {
                        callback(failure, {
                          Error: 'error occured, no access token found.'
                        });
                      }
                    } else {
                      callback(failure, {
                        Error: 'error occured, no access token found.'
                      });
                    }
                    return ph.exit();
                  });
                }, 4000);
              }, mioID, mioPass);
            }
          });
        });
      });
    };

    Coupon.prototype.inform = function(arg) {
      var access_token, callback, client_id, failure, success;
      client_id = arg.client_id, access_token = arg.access_token, success = arg.success, failure = arg.failure;
      callback = utility.callback;
      if (!(client_id && access_token)) {
        callback(failure, new Error('no access_token specified'));
      }
      return require('request')({
        url: this.urls.endpoint,
        method: 'GET',
        headers: {
          'X-IIJmio-Developer': client_id,
          'X-IIJmio-Authorization': access_token
        }
      }, function(err, res, body) {
        if (res.statusCode === 200) {
          return callback(success, {
            information: JSON.parse(body)
          });
        } else {
          return callback(failure, err);
        }
      });
    };

    Coupon.prototype.turn = function(arg) {
      var access_token, callback, client_id, failure, query, success;
      client_id = arg.client_id, access_token = arg.access_token, query = arg.query, success = arg.success, failure = arg.failure;
      callback = utility.callback;
      if (!(client_id && access_token)) {
        callback(failure, new Error('no access_token specified'));
        return;
      }
      if (!query) {
        callback(failure, new Error('no query specified'));
        return;
      }
      return require('request')({
        url: this.urls.endpoint,
        method: 'PUT',
        headers: {
          'X-IIJmio-Developer': client_id,
          'X-IIJmio-Authorization': access_token,
          'Content-Type': 'application/json'
        },
        json: query
      }, function(err, res, body) {
        if (res.statusCode === 200) {
          return callback(success);
        } else {
          return callback(failure, err);
        }
      });
    };

    Coupon.prototype.urls = {
      oAuth: 'https://api.iijmio.jp/mobile/d/v1/authorization/',
      endpoint: 'https://api.iijmio.jp/mobile/d/v1/coupon/'
    };

    return Coupon;

  })();

  utility = {
    arraify: function(numbers) {
      var _, results, transform;
      if (numbers == null) {
        return [];
      }
      _ = require('underscore');
      results = [];
      transform = function(value) {
        var result;
        result = value.toString().replace(/\D/g, '');
        if (result !== '') {
          return results.push(result);
        }
      };
      if (Array.isArray(numbers)) {
        _.each(numbers, transform);
      } else {
        transform(numbers);
      }
      return results;
    },
    orderCouponUse: function(order) {
      if (order === 'on') {
        return true;
      } else if (order === 'off') {
        return false;
      } else {
        return Boolean(order);
      }
    },
    querify: function(arg) {
      var _, couponUse, filter, information, result;
      information = arg.information, couponUse = arg.couponUse, filter = arg.filter;
      if (!information) {
        throw new Error('no source option exception');
      }
      _ = require('underscore');
      couponUse = this.orderCouponUse(couponUse);
      filter = this.arraify(filter);
      result = {
        couponInfo: []
      };
      if (Array.isArray(information.couponInfo)) {
        _.each(information.couponInfo, function(hdd) {
          var each_couponInfo;
          each_couponInfo = {
            hdoInfo: []
          };
          if (Array.isArray(hdd.hdoInfo)) {
            _.each(hdd.hdoInfo, function(hdo) {
              var ref;
              if (hdo.hdoServiceCode && (filter.length === 0 || (filter.length > 0 && (ref = hdo.number, indexOf.call(filter, ref) >= 0)))) {
                return each_couponInfo.hdoInfo.push({
                  hdoServiceCode: hdo.hdoServiceCode,
                  couponUse: couponUse
                });
              }
            });
            if (each_couponInfo.hdoInfo.length > 0) {
              return result.couponInfo.push(each_couponInfo);
            }
          }
        });
      }
      return result;
    },
    callback: function() {
      var args, callback;
      args = Array.prototype.slice.call(arguments);
      if ((typeof args[0]) === 'function') {
        callback = args.shift();
        return callback.apply(callback, args);
      } else {
        return false;
      }
    }
  };

  module.exports.Coupon = Coupon;

  module.exports.utility = utility;

}).call(this);
