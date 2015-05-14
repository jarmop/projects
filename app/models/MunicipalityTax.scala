package models

import play.api.libs.json.{Json, Writes}

case class MunicipalityTax(salary: Int, municipality: String, age: Int) {
  def getTax(): Int = {
    5000
  }

  def getIncomeDeduction(): Int = {
    val municipalityDeductionTable = List[Map[String, Any]](
      Map[String, Any]("minSalary" -> 2500, "maxSalary" -> 7230, "deductionPercent" -> 0.51),
      Map[String, Any]("minSalary" -> 7230, "maxSalary" -> 17600, "deductionPercent" -> 0.28)
    )

    var deduction = 0

    for (deductionMap <- municipalityDeductionTable) {
      deduction = deductionMap.get("minSalary").get.asInstanceOf[Int]
    }


    deduction
  }
}

object MunicipalityTax {
  implicit val municipalityWrites = new Writes[MunicipalityTax] {
    def writes(municipalityTax: MunicipalityTax) = Json.obj(
      "tax" -> municipalityTax.getTax(),
      "deduction" -> municipalityTax.getIncomeDeduction()
    )
  }
}