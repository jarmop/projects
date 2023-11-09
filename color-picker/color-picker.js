const canvasWidth = 500
const canvasHeight = 500

const canvas = document.getElementById('colorPicker')
const ctx = canvas.getContext('2d')

const selectedColorBox = document.getElementById('selectedColor')

const grd = ctx.createLinearGradient(canvasWidth, 0, 0, canvasHeight)
grd.addColorStop(0, 'blue')
grd.addColorStop(1, 'black')

ctx.fillStyle = grd
ctx.fillRect(0, 0, 500, 500)

canvas.addEventListener('click', (event) => {
  const x = event.x
  const y = event.y
  const data = ctx.getImageData(x, y, 1, 1).data

  const rgbaValues = [data[0], data[1], data[2], data[3] / 255]

  selectedColorBox.style.background = `rgba(${rgbaValues.join(', ')})`
})
