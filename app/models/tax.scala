package models

import play.api.libs.json.{Json, Writes}

case class Tax(salary: Float, municipality: String, age: Int, municipalityTax: MunicipalityTax) {
  def this(salary: Float, municipality: String, age: Int) {
    this(salary, municipality, age, MunicipalityTax(salary, municipality, age))
  }
}

object Tax {
  implicit val taxWrites = new Writes[Tax] {
    def writes(tax: Tax) = Json.obj(
      "municipalityTax" -> Json.toJson(tax.municipalityTax),
      "governmentTax" -> Json.obj(
        "tax" -> tax.salary / 5
      )
    )
  }
}