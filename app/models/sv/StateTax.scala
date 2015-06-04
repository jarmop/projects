package models.sv

import play.api.libs.json.{Json, JsObject}
import scala.util.control.Breaks.{breakable, break}
import models._
import services.svKronaToEuro

class StateTax(taxableIncome: Double) {
  var sum: Double = -1
  var sumDeduction: Double = -1

  def getSum: Double = {
    if (this.sum < 0) {
      this.sum = this.calculateSum
    }

    this.sum
  }

  def calculateSum: Double = {
    val taxTable = Map[Double,Double](
      430200.0 -> 0.20,
      616100.0 -> 0.05
    )

    var sum: Double = 0
    breakable { for ( (limit, taxPercent) <- taxTable) {
      if (this.taxableIncome < limit) {
        break
      }
      sum += taxPercent * (this.taxableIncome - limit)
    }}

    sum
  }

  def deductTaxCredit(totalTax: Double, taxCredit: Double) = {
    this.sumDeduction = (this.getSum / totalTax * taxCredit)
    this.sum = substractUntilZero(this.sum, this.sumDeduction)
  }

  def getJson: JsObject = {
    Json.obj(
      "sum" -> svKronaToEuro(this.getSum)
    )
  }
}
