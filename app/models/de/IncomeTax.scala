package models.de

import play.api.Logger
import play.api.libs.json.{Json, JsObject}
import scala.util.control.Breaks.{breakable, break}


class IncomeTax(earnedIncome: Double) {
  case class TaxRate(minIncome: Int, maxIncome: Int, percentIncrease: Double, gh: Double)
  val basicAllowance = 8472 // lohnsteuer.de
  // wikin mukaan 8354 mutta taitaa olla 2014 luku

  var sum: Double = -1

  def getSum: Double = {
    if (this.sum < 0) {
      this.sum = this.calculateSum
    }

    this.sum
  }

  def calculateSum = {
    val taxRates = List[TaxRate](
      TaxRate(8355, 13469, 0.10, 0.10),
      TaxRate(13470, 52881, 0.18, 0.18)
      /*,
      TaxRate(52882, 250730, 0.0, 0),
      TaxRate(250731, 0, 0.45, 0)*/
    )

    var sum: Double = 0
    var previousMax = 8354
    var previousPercent = 0.14
    breakable {
      for ((taxRate) <- taxRates) {
        if (this.earnedIncome <= previousMax)
          break
        var income = this.earnedIncome
        if (income > taxRate.maxIncome)
          income = taxRate.maxIncome
        income = income - previousMax
        var percent = income / (taxRate.maxIncome - previousMax) * taxRate.percentIncrease + previousPercent
        sum += percent * income
        Logger.debug(percent.toString)
        Logger.debug(income.toString)

        previousMax = taxRate.maxIncome
        previousPercent = percent
      }
    }
    sum
  }

  def getJson: JsObject = Json.obj(
    "sum" -> this.getSum
  )


}
