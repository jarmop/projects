package models.sv

import play.api.libs.json.{Json, JsObject}

class MunicipalityTax(taxableIncome: Double, municipality: String, age: Int) {
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

  def getMunicipalityTax: Double = {
    this.municipalityPercent * this.taxableIncome
  }

  def getCountyTax: Double = {
    this.countyPercent * this.taxableIncome
  }

  def getChurchPayment: Double = {
    this.churchPercent * this.taxableIncome
  }

  def getFuneralPayment: Double = {
    this.funeralPercent * this.taxableIncome
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

  def getMunicipalityPercent: Double = {
    this.municipalityPercent
  }

  def getCountyPercent: Double = {
    this.countyPercent
  }

  def getJson: JsObject = {
    Json.obj(
      "municipalityTax" -> this.getMunicipalityTax,
      "countyTax" -> this.getCountyTax,
      "churchPayment" -> this.getChurchPayment,
      "funeralPayment" -> this.getFuneralPayment,
      "totalTax" -> this.getTotalTax
    )
  }
}
