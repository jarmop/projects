// create svg drawing
var draw = SVG('drawing')

// create image
var image = draw.image('images/background.jpg')
image.size(650, 650).y(-150)

// create text
var text = draw.text('SVG.JS').move(300, 0)
text.font({
  family: 'Source Sans Pro'
  , size: 180
  , anchor: 'middle'
  , leading: 1
})

// clip image with text
image.clipWith(text)