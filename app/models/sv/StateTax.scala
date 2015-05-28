package models.sv

import play.api.libs.json.{Json, JsObject}

import scala.util.control.Breaks._

class StateTax(taxableIncome: Double) {
  var earnedIncomeTax: Double = -1

  def getEarnedIncomeTax: Double = {
    if (this.earnedIncomeTax < 0) {
      this.earnedIncomeTax = this.calculateEarnedIncomeTax
    }

    this.earnedIncomeTax
  }

  def calculateEarnedIncomeTax: Double = {
    val taxTable = Map[Double,Double](
      430200.0 -> 0.20,
      616100.0 -> 0.05
    )

    var earnedIncomeTax: Double = 0
    breakable { for ( (limit, taxPercent) <- taxTable) {
      if (this.taxableIncome < limit) {
        break
      }
      earnedIncomeTax += taxPercent * (this.taxableIncome - limit)
    }}

    earnedIncomeTax
  }

  def getJson: JsObject = {
    Json.obj(
      "earnedIncomeTax" -> this.getEarnedIncomeTax
    )
  }
}
