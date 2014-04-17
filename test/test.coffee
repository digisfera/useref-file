path = require('path')
fs = require('fs')
rimraf = require('rimraf')
_ = require('lodash')

expect = require('chai').expect
userefFile = require('../index')

describe 'useref-file', ->

  cssFilesToGenerate = [ 'css/combined.css', 'combined2.css' ]
  jsFilesToGenerate = [ 'scripts/combined.concat.min.js', 'combined2.concat.min.js' ]
  filesToGenerate = cssFilesToGenerate.concat(jsFilesToGenerate)

  testDir = path.join(__dirname, 'testfiles')
  generatedDir = path.join(__dirname, 'tmp')
  expectedDir = path.join(__dirname, 'expected')

  testPath = (f) -> path.join(testDir, f)
  generatedPath = (f) -> path.join(generatedDir, f)
  expectedPath = (f) -> path.join(expectedDir, f)

  beforeEach (done) ->
    rimraf generatedDir, (err) ->
      expect(err).to.be.not.ok
      done()

  it 'should write output and processed files', (done) ->
    userefFile testPath('index.html'), generatedDir, (err, result) ->

      expect(err).to.be.not.ok
      expect(result).to.have.property('css').with.length(2)
      expect(result).to.have.property('js').with.length(2)
      expect(result.css[0]).to.have.property('outputFile').that.equals(generatedPath(cssFilesToGenerate[0]))
      expect(result.css[1]).to.have.property('outputFile').that.equals(generatedPath(cssFilesToGenerate[1]))
      expect(result.js[0]).to.have.property('outputFile').that.equals(generatedPath(jsFilesToGenerate[0]))
      expect(result.js[1]).to.have.property('outputFile').that.equals(generatedPath(jsFilesToGenerate[1]))

      _.each filesToGenerate, (f, i) ->
        generatedContents = fs.readFileSync(generatedPath(f), encoding: 'utf-8')
        expectedContents = fs.readFileSync(expectedPath(f), encoding: 'utf-8')
        expect(generatedContents).to.eql(expectedContents)

      done()

  it 'should uglify js', (done) ->
    userefFile testPath('index.html'), generatedDir, handlers: js: 'uglify', (err, result) ->

      expect(err).to.be.not.ok

      expect(result).to.have.property('css').with.length(2)
      expect(result).to.have.property('js').with.length(2)

      _.each filesToGenerate, (f, i) ->
        generatedContents = fs.readFileSync(generatedPath(f), encoding: 'utf-8')
        expect(generatedContents.length).to.be.greaterThan(0)


      done()

  it 'should strip query and hash from file names', (done) ->
    userefFile testPath('stripquery.html'), generatedDir, (err, result) ->

      expect(err).to.be.not.ok

      _.each cssFilesToGenerate, (f, i) ->
        generatedContents = fs.readFileSync(generatedPath(f), encoding: 'utf-8')
        expectedContents = fs.readFileSync(expectedPath(f), encoding: 'utf-8')
        expect(generatedContents).to.eql(expectedContents)

      done()

  it 'should work in a file without blocks', (done) ->
    userefFile testPath('noblocks.html'), generatedDir, (err, result) ->
      expect(err).to.be.not.ok
      expect(result).to.be.ok
      done()

  it 'should throw error if file does not exist', (done) ->
    userefFile 'invalid file', generatedDir, (err, result) ->
      expect(err).to.be.ok
      expect(result).to.be.not.ok
      done()
