package models.sv

import play.api.Logger
import play.api.libs.json.{Json, JsObject}
import scala.util.control.Breaks.{breakable, break}

class TaxCredit(earnedIncome: Int, nonTaxable: Double, municipalityPercent: Double, pensionContribution: Double) {
  case class Section(limit: Int, percent: Double, addition: Int, deduction: Double)
  var sum: Double = -1

  def getSum: Double = {
    if (this.sum < 0) {
      this.sum = this.calculateSum
    }
    this.sum
  }

  def calculateSum: Double = {
    var approvedIncome = roundDownHundreds(this.earnedIncome)
    if (approvedIncome >= 359600) {
      return this.municipalityPercent * (95897 - this.nonTaxable)
    }

    var sections = List[Section](
      Section(40495, 1, 0, this.pensionContribution),
      Section(130830, 0.332, 40495, 0),
      Section(359599, 0.111, 70488, 0)
    )
    var sum: Double = 0
    var previousSectionLimit = 0

    breakable { for (section <- sections) {
      if (approvedIncome <= section.limit) {
        sum = this.municipalityPercent * (section.percent * (approvedIncome - previousSectionLimit) + section.addition - this.nonTaxable) - section.deduction
        if (sum < 0) sum = 0
        break
      }
      previousSectionLimit = section.limit
    }}
    sum
  }

  def getJson: JsObject = {
    Json.obj(
      "sum" -> this.getSum
    )
  }
}


