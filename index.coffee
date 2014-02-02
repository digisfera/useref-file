path = require('path')

useref = require('useref')
async = require('async')
fs = require('fs')
mkdirp = require('mkdirp')
_ = require('lodash')
concatFun = require('concatenate-files')
uglifyFun = require('uglify-files')

module.exports = (inputFile, outputDir, options, doneCallback) ->
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
      (srcFiles, dstFile, cb) -> uglifyFun(srcFiles, dstFile, {}, cb)
    else null

  options.handlers.css =
    if _.isFunction(options.handlers.css) then options.handlers.css
    else if options.handlers.css == 'concat'
      (srcFiles, dstFile, cb) -> concatFun srcFiles, dstFile, { separator: '' }, cb
    else null

  fs.readFile inputFile, {encoding: 'utf-8'}, (err, inputData) ->
    if err then return doneCallback(err)
    
    [ outHtml, toBuild ] = useref(inputData)

    writeFun = (cb) ->
      mkdirp outputDir, (err, done) ->
        if err then return cb(err)
        fs.writeFile(path.join(outputDir, path.basename(inputFile)), outHtml, cb)
    
    processFun = (cb) ->
      allFuns = []

      _.each toBuild, (block, type) ->
        _.each block, (src, dst) ->
          srcFiles = _.map(src, (p) -> path.join(path.dirname(inputFile), p))
          dstFile = path.join(outputDir, dst)
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