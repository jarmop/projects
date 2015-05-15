package models

import play.api.libs.json.{Json, Writes}
import scala.util.control.Breaks._

case class MunicipalityTax(salary: Int, municipality: String, age: Int) {
  def getTax(): Int = {
    500000
  }

  def getIncomeDeduction(): Double = {
    val municipalityDeductionTable = List[Map[String, Any]](
      Map[String, Any]("minSalary" -> 250000, "maxSalary" -> 723000, "deductionPercent" -> 0.51),
      Map[String, Any]("minSalary" -> 723000, "maxSalary" -> 1760000, "deductionPercent" -> 0.28)
    )

    var deduction: Double = 0
    breakable { for (deductionMap <- municipalityDeductionTable) {
      var minSalary = deductionMap.get("minSalary").get.asInstanceOf[Int]
      if (this.salary < minSalary)
        break
      var maxSalary = deductionMap.get("maxSalary").get.asInstanceOf[Int]
      var deductionPercent = deductionMap.get("deductionPercent").get.asInstanceOf[Double]
      var salaryTemp = if (this.salary < maxSalary) this.salary else maxSalary
      deduction += (salaryTemp - minSalary) * deductionPercent
    }}

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