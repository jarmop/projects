package models.sv

import play.api.Logger
import play.api.libs.json.{Json, JsObject}
import scala.util.control.Breaks.{breakable, break}

class TaxCredit(earnedIncome: Int, nonTaxable: Double, municipalityPercent: Double, pensionContribution: Double) {
  case class Section(limit: Int, percent: Double, addition: Int)
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
      Section(62699, 1, 0),
      //Section(130536, 0.566, 62640)
      Section(131650, 0.566, 62640),
      Section(500000, 0.34, 101700)
    )
    var sum: Double = 0
    var previousSectionLimit = 0

    breakable { for (section <- sections) {
      if (approvedIncome <= section.limit) {
        sum = this.municipalityPercent * (section.percent * (approvedIncome - previousSectionLimit) + section.addition - this.nonTaxable) - this.pensionContribution
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


