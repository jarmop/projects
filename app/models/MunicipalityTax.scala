package models

import play.api.libs.json.{Json, Writes}

case class MunicipalityTax(salary: Float, municipality: String, age: Int)

object MunicipalityTax {
  implicit val municipalityWrites = new Writes[MunicipalityTax] {
    def writes(municipalityTax: MunicipalityTax) = Json.obj(
      "tax" -> 5000
    )
  }
}