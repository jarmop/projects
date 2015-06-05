package models

abstract class AbstractTax(earnedIncome: Double) {
  def getPercentage(value: Double): Double = {
    if (this.earnedIncome > 0) value / this.earnedIncome else 0
  }
}
