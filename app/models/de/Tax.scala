package models.de

import models.{AbstractTax, TaxTrait}
import play.api.libs.json.{Json, JsObject}
import services._

class Tax(earnedIncome: Double, municipality: String, age: Int) extends AbstractTax(earnedIncome) with models.TaxTrait {

  def getTotalTax: Double = {
    0
  }

  def getTotalTaxPercentage: Double = {
    0
  }

  def getJson: JsObject = {
    Json.obj(
      "totalTax" -> svKronaToEuro(this.getTotalTax),
      "totalTaxPercentage" -> this.getTotalTaxPercentage
    )
  }
}