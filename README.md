# useref-file

Useref on a file

## Installation

    npm install useref-file

## Usage

### userefFile(inputFile, outputDir, [options], [callback])

* `inputFiles` - the HTML file to run `useref` on
* `outputDir` - directory to write the resulting HTML file and the concatenated block files
* `options`
  * `handlers` - handlers for each type of block
    * `js` - `'concat'|'uglify'|function` (default: `concat`)
    * `css` - `'concat'|function` (default: `concat`)
* `callback` - function that will be called with `(err, { blockType: { outputFile, outputData } })`


## Example

HTML file:

    <html>
    <head>

      <!-- build:css /css/combined.css -->
      <link href="/css/one.css" rel="stylesheet">
      <link href="/css/two.css" rel="stylesheet">
      <!-- endbuild -->

    </head>
    <body>


      <!-- build:css combined2.css -->
      <link href="/css/three.css" rel="stylesheet">
      <link href="/css/four.css" rel="stylesheet">
      <!-- endbuild -->


    <!-- build:js scripts/combined.concat.min.js -->
    <script type="text/javascript" src="scripts/this.js"></script>
    <script type="text/javascript" src="scripts/that.js"></script>
    <!-- endbuild -->

    <!-- build:js /combined2.concat.min.js -->
    <script type="text/javascript" src="scripts/anotherone.js"></script>
    <script type="text/javascript" src="scripts/yetonemore.js"></script>
    <!-- endbuild -->
    </body>
    </html>


Javascript:

    var userefFile = require('useref-file')

    userefFile('index.html', 'build', { handlers: { js: 'uglify' }}, function(err, result) {
      /* 
        {
          js: {
            { outputFile: 'scripts/combined.concat.min.js', outputData: '...' },
            { outputFile: '/combined2.concat.min.js', outputData: '...' }
          },
          css: {
            { outputFile: '/css/combined.css', outputData: '...' },
            { outputFile: 'combined2.css', outputData: '...' }
          }
      */
    });


## TODO

Support source maps