package models

import play.api.libs.json.{Json, Writes}

case class TaxValue(name: String, sum: Double, percentage: Double)

object TaxValue {
  implicit val taxValueWrites = new Writes[TaxValue] {
    def writes(taxValue: TaxValue) = Json.obj(
      "name" -> taxValue.name,
      "sum" -> taxValue.sum,
      "percentage" -> taxValue.percentage
    )
  }
}