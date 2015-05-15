package models

import play.api.libs.json.{Json, Writes}

case class GovernmentTax(salary: Int, naturalDeduction: Double, commonDeduction: Double) {

}

object GovernmentTax {
  implicit val municipalityWrites = new Writes[MunicipalityTax] {
    def writes(municipalityTax: MunicipalityTax) = Json.obj(
      "tax" -> 500000
    )
  }
}
