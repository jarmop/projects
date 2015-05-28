package models.sv

import play.api.libs.json.{Json, JsObject}

class Tax(salary: Int, municipality: String, age: Int) {
  val municipalityTax = new MunicipalityTax(salary, municipality, age)

  // Tax credit for income from work (earned income tax)
  def getTaxCredit: Double = {
    21163
  }

  def getPensionContribution: Double = {
    21000
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
    this.municipalityTax.getTotalTax - this.getTaxCredit
  }

  def getJson: JsObject = {
    Json.obj(
      "municipalityTax" -> this.municipalityTax.getJson,
      "taxCredit" -> this.getTaxCredit,
      "totalTax" -> this.getTotalTax
    )
  }
}
