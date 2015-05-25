package models.fi

import play.api.libs.json.{Json, JsObject}

class MedicalCareInsurancePayment(deductedMunicipalityTaxSalary: Double) {
  private val medicalCareInsurancePercent = 0.0132

  def getSum: Double = {
    this.deductedMunicipalityTaxSalary * this.medicalCareInsurancePercent
  }

  def getJson: JsObject = {
    Json.obj(
      "percent" -> this.medicalCareInsurancePercent,
      "sum" -> this.getSum
    )
  }
}
