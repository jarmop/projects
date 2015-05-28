package models.sv

import play.api.libs.json.{Json, JsObject}

class MunicipalityTax(salary: Int, municipality: String, age: Int) {
  val municipalityPercents = Map[String, Double]("Stockholm" -> 0.1768)
  val countyPercents = Map[String, Double]("Stockholm" -> 0.1210)
  val churchPercents = Map[String, Double]("Adolf Fred." -> 0.0098)
  val churches = Map[String, List[String]]("Stockholm" -> List[String]("Adolf Fred."))
  val funeralPercents = Map[String, Double]("Stockholm" -> 0.1210)

  val municipalityPercent = this.municipalityPercents.get(this.municipality).get
  val countyPercent = this.countyPercents.get(this.municipality).get
  val church = "Adolf Fred."
  val churchPercent = this.churchPercents.get(this.church).get
  val funeralPercent = this.funeralPercents.get(this.municipality).get

  def getMunicipalityTax: Double = {
    this.municipalityPercent * this.salary
  }

  def getCountyTax: Double = {
    this.countyPercent * this.salary
  }

  def getChurchPayment: Double = {
    this.churchPercent * this.salary
  }

  def getFuneralPayment: Double = {
    this.funeralPercent * this.salary
  }

  def getJson: JsObject = {
    Json.obj(
      "municipalityTax" -> this.getMunicipalityTax,
      "countyTax" -> this.getCountyTax,
      "churchPayment" -> this.getChurchPayment,
      "funeralPayment" -> this.getFuneralPayment
    )
  }
}
