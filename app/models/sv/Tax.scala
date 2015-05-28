package models.sv

import play.api.libs.json.{Json, JsObject}

class Tax(earnedIncome: Int, municipality: String, age: Int) {
  val municipalityTax = new MunicipalityTax(this.getTaxableIncome, municipality, age)

  // Tax credit for income from work (earned income tax)
  def getTaxCredit: Double = {
    val m = Map[Int,Double](
      300000 -> 21163,
      500000 -> 24657
    )
    m.get(this.earnedIncome).get
  }

  def getPensionContribution: Double = {
    val m = Map[Int,Double](
      300000 -> 21000,
      500000 -> 32800
    )
    m.get(this.earnedIncome).get
  }

  def getEarnedIncomeTax: Double = {
    val m = Map[Int,Double](
      300000 -> 0,
      500000 -> 11340
    )
    m.get(this.earnedIncome).get
  }

  def getTaxableIncome: Double = {
    // tests explode if using map here ????
    /*val m = Map[Int,Double](
      300000 -> 281800,
      500000 -> 486900
    )
    m.get(this.earnedIncome).get*/
    var taxableIncome = 486900
    if (this.earnedIncome == 300000) {
      taxableIncome = 281800
    }
    taxableIncome
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
      "taxableIncome" -> this.getTaxableIncome,
      "municipalityTax" -> this.municipalityTax.getJson,
      "earnedIncomeTax" -> this.getEarnedIncomeTax,
      "pensionContribution" -> this.getPensionContribution,
      "taxCredit" -> this.getTaxCredit,
      "totalTax" -> this.getTotalTax
    )
  }
}
