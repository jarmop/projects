package models.sv

import models._
import play.api.Logger
import play.api.libs.json.{Json, JsObject}
import services._

class FuneralPayment(taxableIncome: Double, municipality: String) extends SubTaxTrait {
  val funeralPercents = Map[String, Double]("Stockholm" -> 0.00075)
  val funeralPercent = this.funeralPercents.get(this.municipality).get
  var sum: Double = -1
  var deduction: Double = -1

  def getSum: Double = {
    if (this.sum < 0) {
      this.sum = this.funeralPercent * this.taxableIncome
    }
    this.sum
  }

  def deductTaxCredit(totalTax: Double, taxCredit: Double) = {
    this.deduction = (this.sum / totalTax * taxCredit)
    this.sum = substractUntilZero(this.getSum, this.deduction)
  }

  def getJson: JsObject = {
    Json.obj(
      "sum" -> svKronaToEuro(this.getSum)
    )
  }
}

object FuneralPayment extends SubTaxObjectTrait {
  val name = "Hautajaismaksu"
}