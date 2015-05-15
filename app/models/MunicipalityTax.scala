package models

import play.api.Logger
import play.api.libs.json.{Json, Writes}
import scala.util.control.Breaks._

case class MunicipalityTax(salary: Int, municipality: String, age: Int) {
  val municipalityPercents = Map[String, Double]("Helsinki" -> 0.1850, "Nivala" -> 0.2150)

  var tax: Double = -1
  var deductedSalary: Double = -1
  var incomeDeduction: Double = -1
  var extraIncomeDeduction: Double = -1

  private def getTax(): Double = {
    if (this.tax < 0)
      this.tax = this.getDeductedSalary() * this.getMunicipalityPercent()

    this.tax
  }

  private def getDeductedSalary(): Double = {
    Logger.debug(this.deductedSalary.toString)
    Logger.debug((this.deductedSalary < 0).toString)
    if (this.deductedSalary < 0)
      this.deductedSalary = this.salary - this.getTotalTaxDeduction()



    this.deductedSalary
  }

  private def getTotalTaxDeduction(): Double = {
    return this.getIncomeDeduction() + this.getExtraIncomeDeduction() + this.getCommonDeduction()
  }

  private def getIncomeDeduction(): Double = {
    if (this.incomeDeduction < 0)
      this.incomeDeduction = this.calculateIncomeDeduction()

    return this.incomeDeduction
  }

  private def calculateIncomeDeduction(): Double = {
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

  private def getExtraIncomeDeduction(): Double = {
    if (this.extraIncomeDeduction < 0)
      this.extraIncomeDeduction = this.calculateExtraIncomeDeduction()

    this.extraIncomeDeduction
  }

  private def calculateExtraIncomeDeduction(): Double = {
    var deduction: Double = 0
    var deductedSalary: Double = this.salary - (this.getIncomeDeduction() + this.getCommonDeduction());
    if (deductedSalary <= 19470) {
      var maxDeduction: Double = 2970.0;
      if (deductedSalary < maxDeduction) {
        deduction = deductedSalary;
      } else {
        var deductionDeduction = (deductedSalary - maxDeduction) * 0.18;
        deduction = maxDeduction - deductionDeduction;
      }
    }
    deduction
  }

  private def getCommonDeduction(): Int = {
    620
  }

  private def getMunicipalityPercent(): Double = {
    this.municipalityPercents.get(this.municipality).get
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