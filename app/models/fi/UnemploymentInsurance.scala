package models.fi

import play.api.libs.json.{Json, JsObject}

class UnemploymentInsurance(earnedIncome: Double) {
  private val unemploymentInsurancePercent = 0.0065

  def getSum: Double = {
    this.earnedIncome * this.unemploymentInsurancePercent
  }

  def getJson: JsObject = {
    Json.obj(
      "percent" -> this.unemploymentInsurancePercent,
      "sum" -> this.getSum
    )
  }
}
