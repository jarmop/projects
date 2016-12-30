package models

abstract class AbstractTax(earnedIncome: Double) extends TaxTrait {
  protected val values: List[TaxValue]

  def getPercentage(value: Double): Double = {
    if (this.earnedIncome > 0) value / this.earnedIncome else 0
  }

  def getValues: List[TaxValue] = {
    this.values
  }

  def getValueByName(subTaxName: String): TaxValue = {
    this.getValues.find((taxValue) => taxValue.name == subTaxName).getOrElse(throw new Exception)
  }
}
