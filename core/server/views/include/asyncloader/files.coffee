md5 = window.publicData.md5
u = window.publicData.staticUrl

window.scripts = [
  {
    id: "libraries.css"
    remote: ["#{u}/build/md5/libraries_#{ md5['libraries.css'] }.css"]
    local: "/build/md5/libraries_#{ md5['libraries.css'] }.css"
  }
  {
    id: "style.css"
    remote: ["#{u}/build/md5/style_#{ md5['style.css'] }.css"]
    local: "/build/md5/style_#{ md5['style.css'] }.css"
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
    local: "/build/md5/libraries_#{ md5['libraries.js'] }.js"
  }
  {
    id: "templates.js"
    remote: ["#{u}/build/md5/templates_#{ md5['templates.js'] }.js"]
    local: "/build/md5/templates_#{ md5['templates.js'] }.js"
  }
  {
    id: "main.js"
    remote: ["#{u}/build/md5/main_#{ md5['main.js'] }.js"]
    local: "/build/md5/main_#{ md5['main.js'] }.js"
  }
  {
    id: "fonts.css"
    remote: [
      "//fonts.googleapis.com/css?family=Roboto:300,400,600,700,800"
    ]
  }
]