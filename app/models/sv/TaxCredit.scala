package models.sv

import play.api.Logger
import play.api.libs.json.{Json, JsObject}
import scala.util.control.Breaks.{breakable, break}

class TaxCredit(earnedIncome: Int, nonTaxable: Double, municipalityPercent: Double, pensionContribution: Double) {
  case class Section(min: Int, max: Int, percent: Double, addition: Int)
  var sum: Double = -1

  def getSum: Double = {
    if (this.sum < 0) {
      this.sum = this.calculateSum
    }
    this.sum
  }

  def calculateSum: Double = {
    var sections = List[Section](
      Section(0, 40404, 1, 0),
      Section(40405, 130536, 0.332, 40404)
    )
    var sum: Double = 0
    breakable { for (section <- sections) {
      if (this.earnedIncome >= section.min && this.earnedIncome <= section.max) {
        sum = this.municipalityPercent * (section.percent * this.earnedIncome + section.addition - this.nonTaxable) - this.pensionContribution
        if (sum < 0) sum = 0
        break
      }
    }}
    sum
  }

  def getJson: JsObject = {
    Json.obj(
      "sum" -> this.getSum
    )
  }
}


