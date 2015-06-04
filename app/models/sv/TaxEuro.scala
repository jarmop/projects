package models.sv

import services.{euroToSVKrona, svKronaToEuro}

class TaxEuro(earnedIncome: Double, municipality: String, age: Int) extends SwedishTax {
  val tax = new Tax(euroToSVKrona(earnedIncome), municipality, age)

  def getTotalTaxPercentage: Double = {
    this.tax.getTotalTaxPercentage
  }

  def getTotalTax: Double = {
    svKronaToEuro(this.tax.getTotalTax)
  }

  def getNetIncome: Double = {
    svKronaToEuro(this.tax.getNetIncome)
  }

  def getStateTaxPercentage: Double = {
    svKronaToEuro(this.tax.getStateTaxPercentage)
  }

  def getMunicipalityTaxPercentage: Double = {
    svKronaToEuro(this.tax.getMunicipalityTaxPercentage)
  }

  def getCountyTaxPercentage: Double = {
    svKronaToEuro(this.tax.getCountyTaxPercentage)
  }

  def getChurchPaymentPercentage: Double = {
    svKronaToEuro(this.tax.getChurchPaymentPercentage)
  }

  def getFuneralPaymentPercentage: Double = {
    svKronaToEuro(this.tax.getFuneralPaymentPercentage)
  }

  def getPensionContributionPercentage: Double = {
    svKronaToEuro(this.tax.getPensionContributionPercentage)
  }

  def getTaxCreditPercentage: Double = {
    svKronaToEuro(this.tax.getTaxCreditPercentage)
  }
}
