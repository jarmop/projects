package models

abstract class AbstractTax(earnedIncome: Double) extends TaxTrait {
  def getPercentage(value: Double): Double = {
    if (this.earnedIncome > 0) value / this.earnedIncome else 0
  }

  def getSubTaxValueSetByName(subTaxName: String): SubTaxValueSet = {
    val subTax = this.getSubTaxByName(subTaxName)
    SubTaxValueSet(subTax.getSum, this.getPercentage(subTax.getSum))
  }
}
