package services

object CurrencyConverter {
  val SVkronaRate = 9.3272

  def EuroToSVKrona(value: Double): Double = {
    SVkronaRate * value
  }

  def SVKronaToEuro(value: Double): Double = {
    value / SVkronaRate
  }
}
