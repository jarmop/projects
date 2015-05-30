package models.sv

import play.api.libs.json.{Json, JsObject}
import scala.math.floor

class PensionContribution(earnedIncome: Int) {
  val minIncome = 18782
  val maxIncome = 459183
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
    approvedIncome = floor(approvedIncome / 100) * 100

    this.percent * approvedIncome
  }

  def getDeduction: Double = {
    // TODO pension contribution deduction
    0
  }

  def getJson: JsObject = {
    Json.obj(
      "sum" -> this.getSum,
      "deduction" -> this.getDeduction
    )
  }
}
