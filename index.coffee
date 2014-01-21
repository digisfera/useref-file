fs = require('fs')
path = require('path')

useref = require('useref')
async = require('async')
mkdirp = require('mkdirp')
_ = require('lodash')
concatFun = require('concat-file-fun')

exports.processAll = (inputFile, outputDir, options = {}, doneCallback) ->

  options.handlers ?= {}
  options.handlers.js ?= 'concat'
  options.handlers.css ?= 'concat'

  options.handlers.js =
    if _.isFunction(options.handlers.js) then options.handlers.js
    else if options.handlers.js == 'concat'
      (srcFiles, dstFile, cb) -> concatFun.filesToFile(srcFiles, dstFile, ';', cb)
    else null

  options.handlers.css =
    if _.isFunction(options.handlers.css) then options.handlers.css
    else if options.handlers.css == 'concat'
      (srcFiles, dstFile, cb) -> concatFun.filesToFile(srcFiles, dstFile, '', cb)
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
          allFuns.push((handlerCallback) -> options.handlers[type](srcFiles, dstFile, handlerCallback))

      async.parallel(allFuns, cb)


    async.parallel [writeFun, processFun], (err, result) -> doneCallback(err, result?[1])