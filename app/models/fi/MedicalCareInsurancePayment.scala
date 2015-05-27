package models.fi

import play.api.libs.json.{Json, JsObject}

class MedicalCareInsurancePayment(deductedMunicipalityTaxSalary: Double) {
  private val medicalCareInsurancePercent = 0.0132

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

  def getSum: Double = {
    this.deductedMunicipalityTaxSalary * this.medicalCareInsurancePercent
  }

  def getJson: JsObject = {
    Json.obj(
      "percent" -> this.medicalCareInsurancePercent,
      "sum" -> this.getSum,
      "deductedSum" -> this.getDeductedSum
    )
  }
}
