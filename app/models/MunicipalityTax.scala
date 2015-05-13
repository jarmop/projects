package models

import play.api.libs.json.{Writes, Json}


case class MunicipalityTax(salary: Float, municipality: String, age: Int)

object MunicipalityTax {
  implicit val municipalityWrites = new Writes[MunicipalityTax] {
    def writes(municipalityTax: MunicipalityTax) = Json.obj(
      "tax" -> 5000
    )
  }

  //implicit val municipalityWrites = Json.writes[MunicipalityTax]
}


