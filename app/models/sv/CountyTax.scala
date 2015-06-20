package models.sv

import models._
import play.api.Logger
import play.api.libs.json.{Json, JsObject}
import services._

class CountyTax(taxableIncome: Double, municipality: String) extends SubTaxTrait {
  private val percents = Map[String, Double]("Stockholm" -> 0.1210)
  private val percent = this.percents.get(this.municipality).get
  private var sum: Double = -1
  private var deduction: Double = -1

  def getSum: Double = {
    if (this.sum < 0) {
      this.sum = this.percent * this.taxableIncome
    }
    this.sum
  }

  def getPercent: Double = {
    this.percent
  }

  def deductTaxCredit(totalTax: Double, taxCredit: Double, municipalityTax: Double, pensionContribution: Double) = {
    this.deduction = this.getSum / totalTax * taxCredit + this.getSum / (this.getSum + municipalityTax) * pensionContribution
    this.sum = substractUntilZero(this.getSum, this.deduction)
  }

  def getJson: JsObject = {
    Json.obj(
      "sum" -> svKronaToEuro(this.getSum)
    )
  }
}

object CountyTax extends SubTaxObjectTrait {
  val name = "Maakuntavero"
}