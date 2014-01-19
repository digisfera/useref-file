expect = require('chai').expect
userefFun = require('../index')

describe 'useref-file-fun', ->

  it 'should write output and processed files', (done) ->

    userefFun.processAll "#{__dirname}/testfiles/index.html", "#{__dirname}/tmp", {}, (err, result) ->
      console.log(err)
      console.log(result)
      