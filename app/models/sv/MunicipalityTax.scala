package models.sv

import models.{SubTaxTrait, SubTaxObjectTrait, substractUntilZero}
import services.svKronaToEuro

import play.api.Logger
import play.api.libs.json.{Json, JsObject}

class MunicipalityTax(taxableIncome: Double, municipality: String, age: Int) extends SubTaxTrait {
  val percents = Map[String, Double]("Stockholm" -> 0.1768)
  val percent = this.percents.get(this.municipality).get  
  var sum: Double = -1
  var deduction: Double = -1

  def getSum: Double = {
    if (this.sum < 0) {
      this.sum = this.percent * this.taxableIncome
    }
    this.sum
  }

  def getPercent: Double = {
    this.percent
  }
  
  def deductTaxCredit(totalTax: Double, taxCredit: Double, countyTax: Double, pensionContribution: Double) = {
    this.deduction = this.getSum / totalTax * taxCredit + this.getSum / (this.getSum + countyTax) * pensionContribution
    this.sum = substractUntilZero(this.getSum, this.deduction)
  }

  def getJson: JsObject = {
    Json.obj(
      "sum" -> svKronaToEuro(this.getSum)
    )
  }
}

object MunicipalityTax extends SubTaxObjectTrait {
  val name = "Kunnallisvero"
}
