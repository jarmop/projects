package models.sv

import services.{euroToSVKrona, svKronaToEuro}

class TaxEuro(earnedIncome: Double, municipality: String, age: Int) {
  val tax = new Tax(euroToSVKrona(earnedIncome), municipality, age)

  def getTotalTaxPercentage: Double = {
    this.tax.getTotalTaxPercentage
  }

  def getTotalTax: Double = {
    svKronaToEuro(this.tax.getTotalTax)
  }

  def getNetIncome = {
    svKronaToEuro(this.tax.getNetIncome)
  }
}
