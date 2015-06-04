package models.sv

import play.api.Logger
import play.api.libs.json.{Json, JsObject}
import services.svKronaToEuro

class PensionContribution(earnedIncome: Double) {
  val minIncome = 18824
  val maxIncome = 467900
  var sum: Double = -1
  val percent: Double = 0.07

  def getSum: Double = {
    if (this.sum < 0) {
      this.sum = this.calculateSum
    }
    this.sum
  }

  def calculateSum: Double = {
    if (this.earnedIncome < this.minIncome) {
      return 0
    }
    var approvedIncome: Double = this.earnedIncome
    if (this.earnedIncome > this.maxIncome) {
      approvedIncome = this.maxIncome
    }

    roundHundredsSpecial50(this.percent * roundDownHundreds(approvedIncome))
  }

  def getDeduction: Double = {
    // TODO pension contribution deduction
    0
  }

  def getJson: JsObject = {
    Json.obj(
      "sum" -> svKronaToEuro(this.getSum),
      "deduction" -> svKronaToEuro(this.getDeduction)
    )
  }
}
