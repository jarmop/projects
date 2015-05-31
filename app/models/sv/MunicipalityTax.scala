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
  
  var municipalityTax: Double = -1
  var countyTax: Double = -1
  var churchPayment: Double = -1
  var funeralPayment: Double = -1
  var totalTax: Double = -1

  def getMunicipalityTax: Double = {
    if (this.municipalityTax < 0) {
      this.municipalityTax = this.municipalityPercent * this.taxableIncome
    }
    this.municipalityTax
  }

  def getCountyTax: Double = {
    if (this.countyTax < 0) {
      this.countyTax = this.countyPercent * this.taxableIncome
    }
    this.countyTax
  }

  def getMunicipalityAndCountyTax: Double = {
    this.getMunicipalityTax + this.getCountyTax
  }

  def getChurchPayment: Double = {
    if (this.churchPayment < 0) {
      this.churchPayment = this.churchPercent * this.taxableIncome
    }
    this.churchPayment
  }

  def getFuneralPayment: Double = {
    if (this.funeralPayment < 0) {
      this.funeralPayment = this.funeralPercent * this.taxableIncome
    }
    this.funeralPayment
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

  def getMunicipalityAndCountyPercent: Double = {
    this.getMunicipalityPercent + this.getCountyPercent
  }
  
  def deductTaxCredit(totalTax: Double, taxCredit: Double) = {
    this.municipalityTax -= (this.getMunicipalityTax / totalTax * taxCredit)
    this.countyTax -= (this.getCountyTax / totalTax * taxCredit)
    this.churchPayment -= (this.churchPayment / totalTax * taxCredit)
    this.funeralPayment -= (this.funeralPayment / totalTax * taxCredit)
  }

  def getJson: JsObject = {
    Json.obj(
      "municipalityTax" -> this.getMunicipalityTax,
      "countyTax" -> this.getCountyTax,
      "municipalityAndCountyTax" -> this.getMunicipalityAndCountyTax,
      "municipalityAndCountyPercent" -> this.getMunicipalityAndCountyPercent,
      "churchPayment" -> this.getChurchPayment,
      "funeralPayment" -> this.getFuneralPayment,
      "totalTax" -> this.getTotalTax
    )
  }
}
