package models.sv

import play.api.libs.json.{Json, JsObject}

class Tax(earnedIncome: Int, municipality: String, age: Int) {
  val taxableIncome = new TaxableIncome(this.earnedIncome)
  val municipalityTax = new MunicipalityTax(this.getTaxableIncome, municipality, age)
  val stateTax = new StateTax(this.getTaxableIncome)

  // Tax credit for income from work (earned income tax)
  def getTaxCredit: Double = {
    val m = Map[Int,Double](
      300000 -> 21163,
      500000 -> 24657,
      700000 -> 24657
    )
    m.get(this.earnedIncome).get
  }

  def getPensionContribution: Double = {
    val m = Map[Int,Double](
      300000 -> 21000,
      500000 -> 32800,
      700000 -> 32800
    )
    m.get(this.earnedIncome).get
  }

  def getEarnedIncomeTax: Double = {
    this.stateTax.getEarnedIncomeTax
  }

  def getTaxableIncome: Double = {
    this.taxableIncome.getSum
  }

  def getMunicipalityTax: Double = {
    this.municipalityTax.getMunicipalityTax
  }

  def getCountyTax: Double = {
    this.municipalityTax.getCountyTax
  }

  def getChurchPayment: Double = {
    this.municipalityTax.getChurchPayment
  }

  def getFuneralPayment: Double = {
    this.municipalityTax.getFuneralPayment
  }

  def getTotalTax: Double = {
    this.municipalityTax.getTotalTax + this.getEarnedIncomeTax - this.getTaxCredit
  }

  def getJson: JsObject = {
    Json.obj(
      "taxableIncome" -> this.taxableIncome.getJson,
      "municipalityTax" -> this.municipalityTax.getJson,
      "earnedIncomeTax" -> this.getEarnedIncomeTax,
      "pensionContribution" -> this.getPensionContribution,
      "taxCredit" -> this.getTaxCredit,
      "totalTax" -> this.getTotalTax
    )
  }
}
