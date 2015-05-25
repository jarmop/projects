package models.fi

import play.api.libs.json.{Json, Writes}

import scala.math._
import scala.util.control.Breaks._

case class MunicipalityTax(salary: Int, municipality: String, age: Int, naturalDeduction: Double, commonDeduction: Double) {
  val municipalityPercents = Map[String, Double]("Helsinki" -> 0.1850, "Nivala" -> 0.2150)

  var tax: Double = -1
  var deductedSalary: Double = -1
  var incomeDeduction: Double = -1
  var extraIncomeDeduction: Double = -1

  def getTax: Double = {
    if (this.tax < 0)
      this.tax = this.getDeductedSalary() * this.getMunicipalityPercent()

    this.tax
  }

  def getDeductedSalary(): Double = {
    if (this.deductedSalary < 0)
      this.deductedSalary = this.salary - this.getTotalTaxDeduction()

    this.deductedSalary
  }

  private def getTotalTaxDeduction(): Double = {
    return this.getIncomeDeduction() + this.getExtraIncomeDeduction() + this.commonDeduction
  }

  private def getIncomeDeduction(): Double = {
    if (this.incomeDeduction < 0)
      this.incomeDeduction = this.calculateIncomeDeduction()

    return this.incomeDeduction
  }

  private def calculateIncomeDeduction(): Double = {
    val municipalityDeductionTable = List[Map[String, Double]](
      Map[String, Double]("minSalary" -> 250000, "maxSalary" -> 723000, "deductionPercent" -> 0.51),
      Map[String, Double]("minSalary" -> 723000, "maxSalary" -> 1760000, "deductionPercent" -> 0.28)
    )

    var deduction: Double = 0
    breakable { for (deductionMap <- municipalityDeductionTable) {
      var minSalary = deductionMap.get("minSalary").get
      if (this.salary < minSalary)
        break
      var maxSalary = deductionMap.get("maxSalary").get
      var deductionPercent = deductionMap.get("deductionPercent").get
      var salaryTemp = if (this.salary < maxSalary) this.salary else maxSalary
      deduction += (salaryTemp - minSalary) * deductionPercent
    }}

    var maxDeduction = 357000;
    if (deduction > maxDeduction) {
      deduction = maxDeduction;
    }

    var naturalSalary = this.salary - this.naturalDeduction;
    if (naturalSalary > 1400000) {
      deduction = deduction - 0.045 * (naturalSalary - 1400000);
    }

    if (deduction < 0) {
      deduction = 0;
    }

    deduction
  }

  private def getExtraIncomeDeduction(): Double = {
    if (this.extraIncomeDeduction < 0)
      this.extraIncomeDeduction = this.calculateExtraIncomeDeduction()

    this.extraIncomeDeduction
  }

  private def calculateExtraIncomeDeduction(): Double = {
    var deduction: Double = 0
    var deductedSalary: Double = this.salary - (this.getIncomeDeduction() + this.commonDeduction);
    if (deductedSalary <= 1947000) {
      var maxDeduction: Double = 297000;
      if (deductedSalary < maxDeduction) {
        deduction = deductedSalary;
      } else {
        var deductionDeduction = (deductedSalary - maxDeduction) * 0.18;
        deduction = maxDeduction - deductionDeduction;
      }
    }
    deduction
  }

  private def getMunicipalityPercent(): Double = {
    this.municipalityPercents.get(this.municipality).get
  }
}

object MunicipalityTax {
  implicit val municipalityWrites = new Writes[MunicipalityTax] {
    def writes(municipalityTax: MunicipalityTax) = Json.obj(
      "sum" -> round(municipalityTax.getTax),
      "earnedIncomeAllowance" -> municipalityTax.getIncomeDeduction(),
      "basicDeduction" -> municipalityTax.getExtraIncomeDeduction(),
      "totalDeduction" -> municipalityTax.getTotalTaxDeduction(),
      "deductedSalary" -> municipalityTax.getDeductedSalary()
    )
  }
}