path = require('path')
fs = require('fs')
_ = require('lodash')

expect = require('chai').expect
userefFile = require('../index')

describe 'useref-file', ->

  cssFilesToGenerate = [ 'css/combined.css', 'combined2.css' ]
  jsFilesToGenerate = [ 'scripts/combined.concat.min.js', 'combined2.concat.min.js' ]
  filesToGenerate = cssFilesToGenerate.concat(jsFilesToGenerate)

  outPathJoin = (f) -> path.join(__dirname, 'tmp', f)


  it 'should write output and processed files', (done) ->

    userefFile "#{__dirname}/testfiles/index.html", "#{__dirname}/tmp", (err, result) ->


      expect(err).to.be.not.ok
      expect(result).to.have.property('css').with.length(2)
      expect(result).to.have.property('js').with.length(2)
      expect(result.css[0]).to.have.property('outputFile').that.equals(outPathJoin(cssFilesToGenerate[0]))
      expect(result.css[1]).to.have.property('outputFile').that.equals(outPathJoin(cssFilesToGenerate[1]))
      expect(result.js[0]).to.have.property('outputFile').that.equals(outPathJoin(jsFilesToGenerate[0]))
      expect(result.js[1]).to.have.property('outputFile').that.equals(outPathJoin(jsFilesToGenerate[1]))

      _.each filesToGenerate, (f, i) ->
        generatedContents = fs.readFileSync(path.join(__dirname, 'tmp', f), {encoding: 'utf-8'})
        expectedContents = fs.readFileSync(path.join(__dirname, 'expected', f), {encoding: 'utf-8'})
        expect(generatedContents).to.eql(expectedContents)

      done()

  it 'should uglify js', (done) ->
    userefFile "#{__dirname}/testfiles/index.html", "#{__dirname}/tmp", { handlers: { js: 'uglify' }}, (err, result) ->


      expect(err).to.be.not.ok

      expect(result).to.have.property('css').with.length(2)
      expect(result).to.have.property('js').with.length(2)

      _.each filesToGenerate, (f, i) ->
        generatedContents = fs.readFileSync(path.join(__dirname, 'tmp', f), {encoding: 'utf-8'})
        expect(generatedContents.length).to.be.greaterThan(0)


      done()


  it 'should work in a file without blocks', (done) ->
    userefFile "#{__dirname}/testfiles/noblocks.html", "#{__dirname}/tmp", (err, result) ->
      expect(err).to.be.not.ok
      expect(result).to.be.ok
      done()
