package models

import play.api.libs.json.{Json, Writes}

case class GovernmentTax(salary: Int, naturalDeduction: Double, commonDeduction: Double) {
  def getTax(): Double = {
    500000
  }
}

object GovernmentTax {
  implicit val governmentWrites = new Writes[GovernmentTax] {
    def writes(governmentTax: GovernmentTax) = Json.obj(
      "tax" -> governmentTax.getTax()
    )
  }
}
