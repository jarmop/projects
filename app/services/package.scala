package object services {
  val SVkronaRate = 9.3272

  def euroToSVKrona(value: Double): Double = {
    SVkronaRate * value
  }

  def svKronaToEuro(value: Double): Double = {
    value / SVkronaRate
  }
}
