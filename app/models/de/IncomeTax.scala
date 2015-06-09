package models.de

import play.api.Logger
import play.api.libs.json.{Json, JsObject}

class IncomeTax(earnedIncome: Double, deduction: Double) {
  val taxableIncome = this.earnedIncome - this.deduction
  val basicAllowance = 8472 // lohnsteuer.de
  // wikin mukaan 8354 mutta taitaa olla 2014 luku

  var sum: Double = -1

  def getSum: Double = {
    if (this.sum < 0) {
      this.sum = this.calculateSum
    }

    this.sum
  }

  def calculateSum: Double = {
    if (this.taxableIncome <= 8354) {
      0
    } else if (this.taxableIncome <= 13469) {
      val y = (this.taxableIncome - 8354) / 10000
      (974.58 * y + 1400) * y
    } else if (this.taxableIncome <= 52881) {
      val y = (this.taxableIncome - 13469) / 10000
      (228.74 * y + 2397) * y + 971
    } else if (this.taxableIncome <= 250730) {
      0.42 * this.taxableIncome - 8239
    } else {
      0.45 * this.taxableIncome - 15761
    }
  }

  def getJson: JsObject = Json.obj(
    "sum" -> this.getSum,
    "deduction" -> this.deduction,
    "taxableIncome" -> this.taxableIncome
  )


}
