# basic-administration-template

> A template for administration website

## Build Setup

``` bash
# install dependencies
npm install

# serve with hot reload at localhost:8080
npm run dev

# build for production with minification
npm run build

# build for production and view the bundle analyzer report
npm run build --report
```

For a detailed explanation on how things work, check out the [guide](http://vuejs-templates.github.io/webpack/) and [docs for vue-loader](http://vuejs.github.io/vue-loader).

## Bug
### postcss for iveiw
When you run npm start there maybe a bug called:

> No PostCSS Config found in ...

You need to create a js file named postcss.config.js in ivew/dist/styles and add codes:

``` js
module.exports = {  
  plugins: {  
    'autoprefixer': {browsers: 'last 5 version'}  
  }  
} 
```
