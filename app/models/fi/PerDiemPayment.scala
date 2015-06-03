package models.fi

import play.api.libs.json.{Json, JsObject}

class PerDiemPayment(taxableSalary: Double) {
  private val perDiemPaymentsTyelPercent = 0.0078

  def getSum: Double = {
    this.taxableSalary * this.perDiemPaymentsTyelPercent
  }

  def getJson: JsObject = {
    Json.obj(
      "percent" -> this.perDiemPaymentsTyelPercent,
      "sum" -> this.getSum
    )
  }
}
