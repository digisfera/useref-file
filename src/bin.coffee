path = require('path')
minimist = require('minimist')
userefFile = require('./index')

run = ->
  argv = minimist(process.argv.slice(2))

  inputFile = argv['_'][0]
  outputFile = argv['_'][1]
  options = argv

  if !inputFile || !outputFile then return printUsage()

  for opt of options
    if opt not in [ 'js', 'css', '_' ]
      console.log "Unrecognized option: #{opt}"
      return

  if options.js? and options.js not in [ 'concat', 'uglify' ]
    console.log "Unrecognized JS handler: #{options.js}"
    return

  if options.css? and options.css not in [ 'concat', 'uglify' ]
    console.log "Unrecognized CSS handler: #{options.css}"
    return

  userefOpts =
    handlers:
      js: options.js
      css: options.css

  userefFile inputFile, outputFile, userefOpts, (err, success) ->
    if err then return console.error(err)
    console.log "Wrote:"
    console.log '  - ' + normalizePath(outputFile)
    for type, items of success
      for { outputFile } in items
        console.log '  - ' + normalizePath(outputFile)

printUsage = () ->
  console.log "Usage:"
  console.log ""
  console.log "useref inputFile outputFile --js <uglify|concat> --css <uglify|concat>"
  console.log ""
  console.log "The `inputFile` and `outputFile` arguments are required"

normalizePath = (f) -> f.split(path.sep).join('/')

module.exports = { run }