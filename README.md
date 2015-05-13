# Goodeggs Angular Browserify

browserify a goodeggs angular app/modules

[![build status][travis-badge]][travis-link]
[![npm version][npm-badge]][npm-link]
[![MIT license][license-badge]][license-link]
[![we're hiring][hiring-badge]][hiring-link]


## Usage

```
npm install goodeggs-angular-browserify
```

```coffeescript
angularBrowserify = require('goodeggs-angular-browserify')

angularBrowserify.run({
  src: 'src/index.coffee'
  dest: 'lib'
  bundleName: 'index.js'
  watch: false
}, done)
```

## Contributing

Please follow our [Code of Conduct](https://github.com/goodeggs/goodeggs-angular-browserify/blob/master/CODE_OF_CONDUCT.md)
when contributing to this project.

```
$ git clone https://github.com/goodeggs/goodeggs-angular-browserify && cd goodeggs-angular-browserify
$ npm install
$ npm test
```

_Module scaffold generated by [generator-goodeggs-npm](https://github.com/goodeggs/generator-goodeggs-npm)._


[travis-badge]: http://img.shields.io/travis/goodeggs/goodeggs-angular-browserify.svg?style=flat-square
[travis-link]: https://travis-ci.org/goodeggs/goodeggs-angular-browserify
[npm-badge]: http://img.shields.io/npm/v/goodeggs-angular-browserify.svg?style=flat-square
[npm-link]: https://www.npmjs.org/package/goodeggs-angular-browserify
[license-badge]: http://img.shields.io/badge/license-MIT-blue.svg?style=flat-square
[license-link]: LICENSE.md
[hiring-badge]: https://img.shields.io/badge/we're_hiring-yes-brightgreen.svg?style=flat-square
[hiring-link]: http://goodeggs.jobscore.com/?detail=Open+Source&sid=161
