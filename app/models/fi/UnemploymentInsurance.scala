package models.fi

import models.{SubTaxTrait, SubTaxObjectTrait}
import play.api.libs.json.{Json, JsObject}

class UnemploymentInsurance(earnedIncome: Double) extends SubTaxTrait {
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

object UnemploymentInsurance extends SubTaxObjectTrait {
  val name = "Työttömysvakuutusmaksu"
}