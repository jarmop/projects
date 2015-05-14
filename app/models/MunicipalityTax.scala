package models

import play.api.libs.json.{Json, Writes}

case class MunicipalityTax(salary: Int, municipality: String, age: Int) {
  def getTax(): Int = {
    5000
  }
}

object MunicipalityTax {
  implicit val municipalityWrites = new Writes[MunicipalityTax] {
    def writes(municipalityTax: MunicipalityTax) = Json.obj(
      "tax" -> municipalityTax.getTax()
    )
  }
}