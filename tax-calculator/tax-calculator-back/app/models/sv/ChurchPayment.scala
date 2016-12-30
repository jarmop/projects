package models.sv

import models._
import play.api.libs.json.{Json, JsObject}
import services._

class ChurchPayment(taxableIncome: Double) extends SubTaxTrait {
  val churchPercents = Map[String, Double]("Adolf Fred." -> 0.0098)
  val churches = Map[String, List[String]]("Stockholm" -> List[String]("Adolf Fred."))
  val church = "Adolf Fred."
  val churchPercent = this.churchPercents.get(this.church).get
  var sum: Double = -1
  var deduction: Double = -1

  def deductTaxCredit(totalTax: Double, taxCredit: Double) = {
    this.deduction = (this.getSum / totalTax * taxCredit)
    this.sum = substractUntilZero(this.getSum, this.deduction)
  }

  def getSum: Double = {
    if (this.sum < 0) {
      this.sum = this.churchPercent * this.taxableIncome
    }
    this.sum
  }

  def getJson: JsObject = {
    Json.obj(
      "sum" -> svKronaToEuro(this.getSum)
    )
  }
}

object ChurchPayment extends SubTaxObjectTrait {
  val name = "Kirkollisvero"
}