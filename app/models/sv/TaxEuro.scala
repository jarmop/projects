package models.sv

import models.{AbstractTax, SubTaxValueSet, SubTaxTrait, TaxTrait}
import play.api.libs.json.JsObject
import services.{euroToSVKrona, svKronaToEuro}

class TaxEuro(earnedIncome: Double, municipality: String = "Stockholm", age: Int = 30) extends AbstractTax(earnedIncome) with SwedishTax with TaxTrait {
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

  def getStateTax: Double = {
    svKronaToEuro(this.tax.getStateTax)
  }

  def getStateTaxPercentage: Double = {
    this.tax.getStateTaxPercentage
  }

  def getMunicipalityTax: Double = {
    svKronaToEuro(this.tax.getMunicipalityTax)
  }

  def getMunicipalityTaxPercentage: Double = {
    this.tax.getMunicipalityTaxPercentage
  }

  def getCountyTax: Double = {
    svKronaToEuro(this.tax.getCountyTax)
  }

  def getCountyTaxPercentage: Double = {
    this.tax.getCountyTaxPercentage
  }

  def getChurchPayment: Double = {
    svKronaToEuro(this.tax.getChurchPayment)
  }

  def getChurchPaymentPercentage: Double = {
    this.tax.getChurchPaymentPercentage
  }

  def getFuneralPayment: Double = {
    svKronaToEuro(this.tax.getFuneralPayment)
  }

  def getFuneralPaymentPercentage: Double = {
    this.tax.getFuneralPaymentPercentage
  }

  def getPensionContribution: Double = {
    svKronaToEuro(this.tax.getPensionContribution)
  }

  def getPensionContributionPercentage: Double = {
    this.tax.getPensionContributionPercentage
  }

  def getTaxCredit: Double = {
    svKronaToEuro(this.tax.getTaxCredit)
  }

  def getTaxCreditPercentage: Double = {
    this.tax.getTaxCreditPercentage
  }

  def getJson: JsObject = {
    this.tax.getJson
  }

  def getSubTaxValueSetByName(subTaxName: String): SubTaxValueSet = {
    this.tax.getSubTaxValueSetByName(subTaxName)
  }
}
