path = require('path')
fs = require('fs')
_ = require('lodash')

expect = require('chai').expect
userefFun = require('../index')

describe 'useref-file-fun', ->

  filesToGenerate = [ 'css/combined.css', 'combined2.css', 'scripts/combined.concat.min.js', 'combined2.concat.min.js' ]


  it 'should write output and processed files', (done) ->

    userefFun "#{__dirname}/testfiles/index.html", "#{__dirname}/tmp", {}, (err, result) ->

      expectedResult = _.map(filesToGenerate, (f) -> path.join(__dirname, 'tmp', f))

      expect(err).to.be.not.ok
      expect(result).to.eql(expectedResult)

      _.each filesToGenerate, (f) ->
        generatedContents = fs.readFileSync(path.join(__dirname, 'tmp', f), {encoding: 'utf-8'})
        expectedContents = fs.readFileSync(path.join(__dirname, 'expected', f), {encoding: 'utf-8'})
        expect(generatedContents).to.eql(expectedContents)

      done()

  it 'should uglify js', (done) ->
    userefFun "#{__dirname}/testfiles/index.html", "#{__dirname}/tmp", { handlers: { js: 'uglify' }}, (err, result) ->

      expectedResult = _.map(filesToGenerate, (f) -> path.join(__dirname, 'tmp', f))

      expect(err).to.be.not.ok
      expect(result).to.eql(expectedResult)

      _.each filesToGenerate, (f) ->
        generatedContents = fs.readFileSync(path.join(__dirname, 'tmp', f), {encoding: 'utf-8'})
        expect(generatedContents.length).to.be.greaterThan(0)

      done()

  it 'should work if options argument is not provided'


