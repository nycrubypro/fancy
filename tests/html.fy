require: "../lib/html"

FancySpec describe: HTML with: {
  it: "generates an empty html string when initialized" when: {
    HTML new to_s is: ""
  }

  it: "generates a simple html string" when: {
    h = HTML new
    h html: {
      h head: {
        h title: "Hello"
      }
      h body: {
        h h1: "Hello, World!"
      }
    }

    h to_s is: \
"""<html>
  <head>
    <title>
      Hello
    </title>
  </head>
  <body>
    <h1>
      Hello, World!
    </h1>
  </body>
</html>"""
  }
}
