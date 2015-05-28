package models.sv

import play.api.libs.json.{Json, JsObject}

class Tax(salary: Int, municipality: String, age: Int) {
  val municipalityTax = new MunicipalityTax(salary, municipality, age)

  /*def getEpmloyerTax: Double = {
    1620537.5
  }

  def getMunicipalityAndChurch: Double = {
    885900.0
  }

  def getEarnedIncomeTaxCredit: Double = {
    205500.0
  }*/

  def getJson: JsObject = {
    Json.obj(
      "municipalityTax" -> this.municipalityTax.getJson
    )
  }
}
