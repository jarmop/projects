package models.fi

import play.api.libs.json.{Json, JsObject}

class YLETax(salary: Int, incomeDeduction: Double) {
  private val taxPercent = 0.0068
  private var taxableSalary: Double = -1

  private def getDeduction: Double = {
    return this.incomeDeduction
  }

  private def getDeductedSalary: Double = {
    this.salary - this.getDeduction
  }

  private def getSalary: Double = {
    if (this.taxableSalary < 0)
      this.taxableSalary = this.getDeductedSalary

    this.taxableSalary
  }

  def getTax: Double = {
    var salary = this.getSalary

    if (salary < 750000) {
      return 0
    }
    if (salary >= 2102900) {
      return 14300
    }

    return salary * this.taxPercent;
  }

  def getJson: JsObject = {
    Json.obj(
      "percent" -> this.taxPercent,
      "sum" -> this.getTax,
      "deduction" -> this.getDeduction,
      "deductedSalary" -> this.getDeductedSalary
    )
  }

}
