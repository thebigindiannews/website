u = window.publicData.staticUrl
window.scripts = [
  {
    id: "style.css"
    remote: ["#{u}/build/md5/style_#{ publicData.md5['style.css'] }.css"]
    local: "/build/md5/style_#{ publicData.md5['style.css'] }.css"
  }
  {
    id: "libraries.js"
    remote: [
      "//ajax.googleapis.com/ajax/libs/angularjs/1.4.0/angular.min.js"
      "//cdnjs.cloudflare.com/ajax/libs/angular-hotkeys/1.4.5/hotkeys.min.js"
      "//cdnjs.cloudflare.com/ajax/libs/angular.js/1.4.0/angular-cookies.min.js"
      "//cdnjs.cloudflare.com/ajax/libs/angular-ui-router/0.2.14/angular-ui-router.min.js"
      "//cdnjs.cloudflare.com/ajax/libs/backbone.js/1.2.3/backbone-min.js"
    ]
    local: "/build/md5/libraries_#{ publicData.md5['libraries.js'] }.js"
  }
  {
    id: "templates.js"
    remote: ["#{u}/build/md5/templates_#{ publicData.md5['templates.js'] }.js"]
    local: "/build/md5/templates_#{ publicData.md5['templates.js'] }.js"
  }
  {
    id: "main.js"
    remote: ["#{u}/build/md5/main_#{ publicData.md5['main.js'] }.js"]
    local: "/build/md5/main_#{ publicData.md5['main.js'] }.js"
  }
  {
    id: "fonts.css"
    remote: [
      "//cdnjs.cloudflare.com/ajax/libs/font-awesome/4.3.0/css/font-awesome.min.css"
      "//fonts.googleapis.com/css?family=Cantarell"
      "//fonts.googleapis.com/css?family=Roboto:400,700"
      "//fonts.googleapis.com/css?family=Source+Sans+Pro:900,400,700"
    ]
  }
]