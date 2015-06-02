package models.sv

import models.AbstractTax
import play.api.Logger
import play.api.libs.json.{Json, JsObject}

class Tax(earnedIncome: Double, municipality: String, age: Int) extends AbstractTax(earnedIncome) {
  val taxableIncome = new TaxableIncome(this.earnedIncome)
  val pensionContribution = new PensionContribution(this.earnedIncome)
  val municipalityTax = new MunicipalityTax(this.getTaxableIncome, municipality, age)
  val stateTax = new StateTax(this.getTaxableIncome)
  val taxCredit = new TaxCredit(this.earnedIncome, this.taxableIncome.getNonTaxable, this.municipalityTax.getMunicipalityPercent + this.municipalityTax.getCountyPercent, this.getPensionContribution)

  this.deductTaxCredit

  // Tax credit for income from work (earned income tax)
  def getTaxCredit: Double = {
    this.taxCredit.getSum
  }

  def getTaxCreditPercentage: Double = {
    this.getPercentage(this.getTaxCredit)
  }

  def getTaxableIncome: Double = {
    this.taxableIncome.getSum
  }

  def getPensionContribution: Double = {
    this.pensionContribution.getSum
  }

  def getPensionContributionPercentage: Double = {
    this.getPercentage(this.getPensionContribution)
  }

  def getStateTax: Double = {
    this.stateTax.getSum
  }

  def getStateTaxPercentage: Double = {
    this.getPercentage(this.getStateTax)
  }

  def getMunicipalityTax: Double = {
    this.municipalityTax.getMunicipalityTax
  }

  def getMunicipalityTaxPercentage: Double = {
    this.getPercentage(this.getMunicipalityTax)
  }

  def getCountyTax: Double = {
    this.municipalityTax.getCountyTax
  }

  def getCountyTaxPercentage: Double = {
    if (this.earnedIncome > 0) this.getCountyTax / this.earnedIncome else 0
  }

  def getChurchPayment: Double = {
    this.municipalityTax.getChurchPayment
  }

  def getChurchPaymentPercentage: Double = {
    if (this.earnedIncome > 0) this.getChurchPayment / this.earnedIncome else 0
  }

  def getFuneralPayment: Double = {
    this.municipalityTax.getFuneralPayment
  }

  def getFuneralPaymentPercentage: Double = {
    if (this.earnedIncome > 0) this.getFuneralPayment / this.earnedIncome else 0
  }

  def getTotalTax: Double = {
    this.municipalityTax.getTotalTax + this.getStateTax + this.getPensionContribution
  }

  def getTotalTaxPercentage: Double = {
    if (this.earnedIncome > 0) this.getTotalTax / this.earnedIncome else 0
  }

  def deductTaxCredit = {
    if (this.getTaxCredit > 0) {
      this.municipalityTax.deductTaxCredit(this.getTotalTax, this.getTaxCredit + this.getPensionContribution)
      this.stateTax.deductTaxCredit(this.getTotalTax, this.getTaxCredit + this.getPensionContribution)
    }
  }

  def getJson: JsObject = {
    Json.obj(
      "taxableIncome" -> this.taxableIncome.getJson,
      "municipalityTax" -> this.municipalityTax.getJson,
      "stateTax" -> this.stateTax.getJson,
      "pensionContribution" -> this.pensionContribution.getJson,
      "taxCredit" -> this.taxCredit.getJson,
      "totalTax" -> this.getTotalTax,
      "totalTaxPercentage" -> this.getTotalTaxPercentage
    )
  }
}
