package models.sv

import play.api.libs.json.{Json, JsObject}

class MunicipalityTax(salary: Int, municipality: String, age: Int) {
  val municipalityPercents = Map[String, Double]("Stockholm" -> 0.1768)
  val countyPercents = Map[String, Double]("Stockholm" -> 0.1210)
  val churchPercents = Map[String, Double]("Adolf Fred." -> 0.0098)
  val churches = Map[String, List[String]]("Stockholm" -> List[String]("Adolf Fred."))
  val funeralPercents = Map[String, Double]("Stockholm" -> 0.00075)

  val municipalityPercent = this.municipalityPercents.get(this.municipality).get
  val countyPercent = this.countyPercents.get(this.municipality).get
  val church = "Adolf Fred."
  val churchPercent = this.churchPercents.get(this.church).get
  val funeralPercent = this.funeralPercents.get(this.municipality).get

  var totalTax: Double = -1

  def getTaxableIncome: Double = {
    281800.0
  }

  def getMunicipalityTax: Double = {
    this.municipalityPercent * this.getTaxableIncome
  }

  def getCountyTax: Double = {
    this.countyPercent * this.getTaxableIncome
  }

  def getChurchPayment: Double = {
    this.churchPercent * this.getTaxableIncome
  }

  def getFuneralPayment: Double = {
    this.funeralPercent * this.getTaxableIncome
  }

  def getTotalTax: Double = {
    if (this.totalTax < 0) {
      this.totalTax = this.calculateTotalTax
    }

    this.totalTax
  }

  def calculateTotalTax: Double = {
    this.getMunicipalityTax + this.getCountyTax + this.getChurchPayment + this.getFuneralPayment
  }

  def getJson: JsObject = {
    Json.obj(
      "taxableIncome" -> this.getTaxableIncome,
      "municipalityTax" -> this.getMunicipalityTax,
      "countyTax" -> this.getCountyTax,
      "churchPayment" -> this.getChurchPayment,
      "funeralPayment" -> this.getFuneralPayment,
      "totalTax" -> this.getTotalTax
    )
  }
}
