# useref-file

Useref on a file

## Installation

    npm install useref-file

## Usage

### userefFile(inputFile, outputFile, [options], [callback])

* `inputFile` - the HTML file to run `useref` on
* `outputFile` - resulting HTML file. The concatenated block files will be located relative to this file.
* `options`
  * `handlers` - handlers for each type of block
    * `js` - `'concat'|'uglify'|function` (default: `concat`)
    * `css` - `'concat'|'uglify'|function` (default: `concat`)
* `callback` - function that will be called with `(err, { blockType: { outputFile, outputData } })`

### CLI

`useref inputFile outputFile --js <concat|uglify> --css <concat|uglify>`


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