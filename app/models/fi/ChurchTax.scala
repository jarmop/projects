package models.fi

import play.api.libs.json.{Json, JsObject}

class ChurchTax(earnedIncome: Double, municipality: String, municipalityDeduction: Double, church: String = "evangelicLutheran") {
  var deductedSalary: Double = -1

  val taxPercents = Map[String, Map[String, Double]](
    "Helsinki" -> Map[String, Double]("evangelicLutheran" -> 0.01, "orthodox" -> 0.0175),
    "Nivala" -> Map[String, Double]("evangelicLutheran" -> 0.016, "orthodox" -> 0.0195)
  )

  val taxPercent = this.taxPercents.get(this.municipality).get.get(this.church).get

  var deductedSum: Double = 0

  def getDeductedSum = {
    this.deductedSum
  }

  def reduceWorkIncomeDeduction(totalDeductableTax: Double, leftOverWorkIncomeDeduction: Double) = {
    if (totalDeductableTax == 0) {
      this.deductedSum = 0
    } else if (leftOverWorkIncomeDeduction == 0) {
      this.deductedSum = this.getSum
    } else {
      this.deductedSum = this.getSum - this.getSum / totalDeductableTax * leftOverWorkIncomeDeduction
      if (this.deductedSum < 0) {
        this.deductedSum = 0
      }
    }
  }

  def getDeduction: Double = {
    this.municipalityDeduction
  }

  def getDeductedSalary: Double = {
    if (this.deductedSalary < 0) {
      this.deductedSalary = this.calculateDeductedSalary
    }
    this.deductedSalary
  }

  def calculateDeductedSalary: Double = {
    var deductedSalary = this.earnedIncome - this.municipalityDeduction
    if (deductedSalary < 0) {
      deductedSalary = 0
    }
    deductedSalary
  }

  def getSum: Double = {
    this.taxPercent * this.getDeductedSalary
  }

  def getJson: JsObject = {
    Json.obj(
      "percent" -> this.taxPercent,
      "sum" -> this.getSum,
      "deductedSum" -> this.getDeductedSum,
      "deduction" -> this.getDeduction,
      "deductedSalary" -> this.getDeductedSalary
    )
  }
}
