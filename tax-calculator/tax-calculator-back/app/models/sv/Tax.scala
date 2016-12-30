package models.sv

import models._
import play.api.Logger
import play.api.libs.json.{Json, JsObject}
import services.{Data, svKronaToEuro}

import scala.collection.mutable.ListBuffer

class Tax(earnedIncome: Double, municipality: String, age: Int) extends AbstractTax(earnedIncome) with SwedishTax with TaxTrait {
  val taxableIncome = new TaxableIncome(this.earnedIncome)
  val pensionContribution = new PensionContribution(this.earnedIncome)
  val municipalityTax = new MunicipalityTax(this.getTaxableIncome, municipality, age)
  val countyTax = new CountyTax(this.getTaxableIncome, municipality)
  val churchPayment = new ChurchPayment(this.getTaxableIncome)
  val funeralPayment = new FuneralPayment(this.getTaxableIncome, municipality)
  val stateTax = new StateTax(this.getTaxableIncome)
  val taxCredit = new TaxCredit(this.earnedIncome, this.taxableIncome.getNonTaxable, this.municipalityTax.getPercent + this.countyTax.getPercent, this.getPensionContribution)

  this.deductTaxCredit

  val values = List[TaxValue](
    TaxValue(PensionContribution.name, this.getPensionContribution, this.getPensionContributionPercentage),
    TaxValue(ChurchPayment.name, this.getChurchPayment, this.getChurchPaymentPercentage),
    TaxValue(FuneralPayment.name, this.getFuneralPayment, this.getFuneralPaymentPercentage),
    TaxValue(CountyTax.name, this.getCountyTax, this.getCountyTaxPercentage),
    TaxValue(MunicipalityTax.name, this.getMunicipalityTax, this.getMunicipalityTaxPercentage),
    TaxValue(StateTax.name, this.getStateTax, this.getStateTaxPercentage)
  )

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
    this.municipalityTax.getSum
  }

  def getMunicipalityTaxPercentage: Double = {
    this.getPercentage(this.getMunicipalityTax)
  }

  def getCountyTax: Double = {
    this.countyTax.getSum
  }

  def getCountyTaxPercentage: Double = {
    if (this.earnedIncome > 0) this.getCountyTax / this.earnedIncome else 0
  }

  def getChurchPayment: Double = {
    this.churchPayment.getSum
  }

  def getChurchPaymentPercentage: Double = {
    if (this.earnedIncome > 0) this.getChurchPayment / this.earnedIncome else 0
  }

  def getFuneralPayment: Double = {
    this.funeralPayment.getSum
  }

  def getFuneralPaymentPercentage: Double = {
    if (this.earnedIncome > 0) this.getFuneralPayment / this.earnedIncome else 0
  }

  def getTotalTax: Double = {
    this.getMunicipalityTax + this.getCountyTax + this.getChurchPayment + this.getFuneralPayment + this.getStateTax + this.getPensionContribution
  }

  def getTotalTaxPercentage: Double = {
    if (this.earnedIncome > 0) this.getTotalTax / this.earnedIncome else 0
  }

  def deductTaxCredit = {
    val totalTax = this.getTotalTax
    val municipalityTax = this.getMunicipalityTax
    val countyTax = this.getCountyTax
    this.municipalityTax.deductTaxCredit(totalTax, this.getTaxCredit, countyTax, this.getPensionContribution)
    this.countyTax.deductTaxCredit(totalTax, this.getTaxCredit, municipalityTax, this.getPensionContribution)
    this.churchPayment.deductTaxCredit(totalTax, this.getTaxCredit)
    this.funeralPayment.deductTaxCredit(totalTax, this.getTaxCredit)
    this.stateTax.deductTaxCredit(this.getTotalTax, this.getTaxCredit + this.getPensionContribution)
  }

  def getNetIncome: Double = {
    this.earnedIncome - this.getTotalTax
  }

  def getJson: JsObject = {
    Json.obj(
      "taxes" -> Json.obj(
        "municipalityTax" -> this.municipalityTax.getJson,
        "stateTax" -> this.stateTax.getJson,
        "pensionContribution" -> this.pensionContribution.getJson
      ),
      "taxableIncome" -> this.taxableIncome.getJson,
      "taxCredit" -> this.taxCredit.getJson,
      "totalTax" -> svKronaToEuro(this.getTotalTax),
      "totalTaxPercentage" -> this.getTotalTaxPercentage,
      "netIncome" -> svKronaToEuro(this.getNetIncome)
    )
  }
}
