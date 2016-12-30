package models.fi

import models.{SubTaxTrait, SubTaxObjectTrait}
import play.api.libs.json.{Json, JsObject}

class PerDiemPayment(taxableSalary: Double) extends SubTaxTrait {
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

object PerDiemPayment extends SubTaxObjectTrait {
  val name = "Päivärahamaksu"
}