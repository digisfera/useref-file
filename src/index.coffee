path = require('path')

useref = require('node-useref')
async = require('async')
fs = require('fs')
path = require('path')
mkdirp = require('mkdirp')
_ = require('lodash')
concatFun = require('concatenate-files')
jsUglifyFun = require('uglify-files')

cssUglifyFun = (srcFiles, dstFile, options, cb) ->

  CleanCss = require('clean-css')

  defaultOptions = noAdvanced: true, compatibility: 'ie8'
  options = _.extend(defaultOptions, options)

  async.map srcFiles, fs.readFile, (err, result) ->
    if err then return cb(err)
    css = result.join('\n')
    try
      minCss = new CleanCss(options).minify(css)
    catch err
      return cb(err)
    mkdirp path.dirname(dstFile), (err) ->
      if err then return cb(err)
      fs.writeFile dstFile, minCss, cb

# Regex to strip query string and hash from path. $1 is the stripped path.
pathRegex = /^([^\?#]*)(?:\?[^\#]*)?(?:#.*)?$/

module.exports = (inputFile, outputFile, options, doneCallback) ->
  if !doneCallback and _.isFunction(options)
    doneCallback = options
    options = null

  options ?= {}
  options.handlers ?= {}
  options.handlers.js ?= 'concat'
  options.handlers.css ?= 'concat'

  options.handlers.js =
    if _.isFunction(options.handlers.js) then options.handlers.js
    else if options.handlers.js == 'concat'
      (srcFiles, dstFile, cb) -> concatFun srcFiles, dstFile, { separator: ';' }, cb
    else if options.handlers.js == 'uglify'
      (srcFiles, dstFile, cb) -> jsUglifyFun(srcFiles, dstFile, {}, cb)
    else null

  options.handlers.css =
    if _.isFunction(options.handlers.css) then options.handlers.css
    else if options.handlers.css == 'concat'
      (srcFiles, dstFile, cb) -> concatFun srcFiles, dstFile, { separator: '' }, cb
    else if options.handlers.css == 'uglify'
      (srcFiles, dstFile, cb) -> cssUglifyFun(srcFiles, dstFile, {}, cb)
    else null

  fs.readFile inputFile, {encoding: 'utf-8'}, (err, inputData) ->
    if err then return doneCallback(err)
    
    [ outHtml, toBuild ] = useref(inputData)

    outputDir = path.dirname(outputFile)
    writeFun = (cb) ->
      mkdirp outputDir, (err, done) ->
        if err then return cb(err)
        fs.writeFile(outputFile, outHtml, cb)
    
    processFun = (cb) ->
      allFuns = []

      _.each toBuild, (block, type) ->
        _.each block, ({ assets: src }, dst) ->
          srcFiles = _.map(src, (p) -> path.join(path.dirname(inputFile), p))
          dstName = pathRegex.exec(dst)[1] or dst
          dstFile = path.join(outputDir, dstName)
          allFuns.push (handlerCallback) ->
            options.handlers[type] srcFiles, dstFile, (err, result) ->
              if err then handlerCallback(err)
              else handlerCallback(null, { type, result} )

      async.parallel(allFuns, cb)


    async.parallel [writeFun, processFun], (err, result) ->
      if(err) then return doneCallback(err)
      
      resultsPerType = _.groupBy(result?[1], 'type')
      blockResults = _.mapValues(resultsPerType, (typeResults) -> _.map(typeResults, 'result'))
      doneCallback(err, blockResults)