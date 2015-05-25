package models.fi

import play.api.libs.json.{Json, JsObject}

class UnemploymentInsurance(salary: Int) {
  private val unemploymentInsurancePercent = 0.0065

  def getSum: Double = {
    this.salary * this.unemploymentInsurancePercent
  }

  def getJson: JsObject = {
    Json.obj(
      "percent" -> this.unemploymentInsurancePercent,
      "sum" -> this.getSum
    )
  }
}
