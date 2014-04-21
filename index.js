// Generated by CoffeeScript 1.7.1
(function() {
  var async, concatFun, cssUglifyFun, fs, jsUglifyFun, mkdirp, path, pathRegex, useref, _;

  path = require('path');

  useref = require('node-useref');

  async = require('async');

  fs = require('fs');

  path = require('path');

  mkdirp = require('mkdirp');

  _ = require('lodash');

  concatFun = require('concatenate-files');

  jsUglifyFun = require('uglify-files');

  cssUglifyFun = function(srcFiles, dstFile, options, cb) {
    var CleanCss, defaultOptions;
    CleanCss = require('clean-css');
    defaultOptions = {
      noAdvanced: true,
      compatibility: 'ie8'
    };
    options = _.extend(defaultOptions, options);
    return async.map(srcFiles, fs.readFile, function(err, result) {
      var css, minCss;
      if (err) {
        return cb(err);
      }
      css = result.join('\n');
      try {
        minCss = new CleanCss(options).minify(css);
      } catch (_error) {
        err = _error;
        return cb(err);
      }
      return mkdirp(path.dirname(dstFile), function(err) {
        if (err) {
          return cb(err);
        }
        return fs.writeFile(dstFile, minCss, cb);
      });
    });
  };

  pathRegex = /^([^\?#]*)(?:\?[^\#]*)?(?:#.*)?$/;

  module.exports = function(inputFile, outputDir, options, doneCallback) {
    var _base, _base1;
    if (!doneCallback && _.isFunction(options)) {
      doneCallback = options;
      options = null;
    }
    if (options == null) {
      options = {};
    }
    if (options.handlers == null) {
      options.handlers = {};
    }
    if ((_base = options.handlers).js == null) {
      _base.js = 'concat';
    }
    if ((_base1 = options.handlers).css == null) {
      _base1.css = 'concat';
    }
    options.handlers.js = _.isFunction(options.handlers.js) ? options.handlers.js : options.handlers.js === 'concat' ? function(srcFiles, dstFile, cb) {
      return concatFun(srcFiles, dstFile, {
        separator: ';'
      }, cb);
    } : options.handlers.js === 'uglify' ? function(srcFiles, dstFile, cb) {
      return jsUglifyFun(srcFiles, dstFile, {}, cb);
    } : null;
    options.handlers.css = _.isFunction(options.handlers.css) ? options.handlers.css : options.handlers.css === 'concat' ? function(srcFiles, dstFile, cb) {
      return concatFun(srcFiles, dstFile, {
        separator: ''
      }, cb);
    } : options.handlers.css === 'uglify' ? function(srcFiles, dstFile, cb) {
      return cssUglifyFun(srcFiles, dstFile, {}, cb);
    } : null;
    return fs.readFile(inputFile, {
      encoding: 'utf-8'
    }, function(err, inputData) {
      var outHtml, processFun, toBuild, writeFun, _ref;
      if (err) {
        return doneCallback(err);
      }
      _ref = useref(inputData), outHtml = _ref[0], toBuild = _ref[1];
      writeFun = function(cb) {
        return mkdirp(outputDir, function(err, done) {
          if (err) {
            return cb(err);
          }
          return fs.writeFile(path.join(outputDir, path.basename(inputFile)), outHtml, cb);
        });
      };
      processFun = function(cb) {
        var allFuns;
        allFuns = [];
        _.each(toBuild, function(block, type) {
          return _.each(block, function(_arg, dst) {
            var dstFile, dstName, src, srcFiles;
            src = _arg.assets;
            srcFiles = _.map(src, function(p) {
              return path.join(path.dirname(inputFile), p);
            });
            dstName = pathRegex.exec(dst)[1] || dst;
            dstFile = path.join(outputDir, dstName);
            return allFuns.push(function(handlerCallback) {
              return options.handlers[type](srcFiles, dstFile, function(err, result) {
                if (err) {
                  return handlerCallback(err);
                } else {
                  return handlerCallback(null, {
                    type: type,
                    result: result
                  });
                }
              });
            });
          });
        });
        return async.parallel(allFuns, cb);
      };
      return async.parallel([writeFun, processFun], function(err, result) {
        var blockResults, resultsPerType;
        if (err) {
          return doneCallback(err);
        }
        resultsPerType = _.groupBy(result != null ? result[1] : void 0, 'type');
        blockResults = _.mapValues(resultsPerType, function(typeResults) {
          return _.map(typeResults, 'result');
        });
        return doneCallback(err, blockResults);
      });
    });
  };

}).call(this);
