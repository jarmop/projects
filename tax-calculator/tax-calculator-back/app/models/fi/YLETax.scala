package models.fi

import models.{SubTaxTrait, SubTaxObjectTrait}
import play.api.libs.json.{Json, JsObject}

class YLETax(earnedIncome: Double, incomeDeduction: Double) extends SubTaxTrait {
  private val taxPercent = 0.0068
  private var taxableSalary: Double = -1

  private def getDeduction: Double = {
    return this.incomeDeduction
  }

  private def getDeductedSalary: Double = {
    this.earnedIncome - this.getDeduction
  }

  private def getSalary: Double = {
    if (this.taxableSalary < 0)
      this.taxableSalary = this.getDeductedSalary

    this.taxableSalary
  }

  def getSum: Double = {
    var salary = this.getSalary

    if (salary < 7500) {
      return 0
    }
    if (salary >= 21029) {
      return 143
    }

    return salary * this.taxPercent;
  }

  def getJson: JsObject = {
    Json.obj(
      "percent" -> this.taxPercent,
      "sum" -> this.getSum,
      "deduction" -> this.getDeduction,
      "deductedSalary" -> this.getDeductedSalary
    )
  }

}

object YLETax extends SubTaxObjectTrait {
  val name = "YLE-vero"
}
