package models.fi

import play.api
import play.api.Logger
import play.api.libs.json.{JsObject, Json}
import scala.math._
import scala.util.control.Breaks._

class MunicipalityTax(salary: Int, municipality: String, age: Int, naturalDeduction: Double, commonDeduction: Double) {
  val municipalityPercents = Map[String, Double]("Helsinki" -> 0.1850, "Nivala" -> 0.2150)

  var tax: Double = -1
  var deductedSum: Double = 0
  var deductedSalary: Double = -1
  var incomeDeduction: Double = -1
  var extraIncomeDeduction: Double = -1

  def getSum: Double = {
    if (this.tax < 0)
      this.tax = this.getDeductedSalary * this.getMunicipalityPercent

    this.tax
  }

  def getDeductedSalary: Double = {
    if (this.deductedSalary < 0)
      this.deductedSalary = this.salary - this.getTotalTaxDeduction

    this.deductedSalary
  }

  def getTotalTaxDeduction: Double = {
    return this.getIncomeDeduction + this.getExtraIncomeDeduction + this.commonDeduction
  }

  private def getIncomeDeduction: Double = {
    if (this.incomeDeduction < 0)
      this.incomeDeduction = this.calculateIncomeDeduction

    return this.incomeDeduction
  }

  private def calculateIncomeDeduction: Double = {
    val municipalityDeductionTable = List[Map[String, Double]](
      Map[String, Double]("minSalary" -> 2500, "maxSalary" -> 7230, "deductionPercent" -> 0.51),
      Map[String, Double]("minSalary" -> 7230, "maxSalary" -> 17600, "deductionPercent" -> 0.28)
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

    var maxDeduction = 3570;
    if (deduction > maxDeduction) {
      deduction = maxDeduction;
    }

    var naturalSalary = this.salary - this.naturalDeduction;
    if (naturalSalary > 14000) {
      deduction = deduction - 0.045 * (naturalSalary - 14000);
    }

    if (deduction < 0) {
      deduction = 0;
    }

    deduction
  }

  private def getExtraIncomeDeduction: Double = {
    if (this.extraIncomeDeduction < 0)
      this.extraIncomeDeduction = this.calculateExtraIncomeDeduction

    this.extraIncomeDeduction
  }

  private def calculateExtraIncomeDeduction: Double = {
    var deduction: Double = 0
    var deductedSalary: Double = this.salary - (this.getIncomeDeduction + this.commonDeduction);
    if (deductedSalary <= 19470) {
      var maxDeduction: Double = 2970;
      if (deductedSalary < maxDeduction) {
        deduction = deductedSalary;
      } else {
        var deductionDeduction = (deductedSalary - maxDeduction) * 0.18;
        deduction = maxDeduction - deductionDeduction;
      }
    }
    deduction
  }

  private def getMunicipalityPercent: Double = {
    this.municipalityPercents.get(this.municipality).get
  }

  def getDeductedSum = {
    this.deductedSum
  }

  def reduceWorkIncomeDeduction(totalDeductableTax: Double, leftOverWorkIncomeDeduction: Double) = {
    if (totalDeductableTax == 0) {
      this.deductedSum = 0
    } else if (leftOverWorkIncomeDeduction == 0) {
      this.deductedSum = this.getSum
    } else {
      this.deductedSum = this.getSum - this.getSum / totalDeductableTax * leftOverWorkIncomeDeduction
      if (this.deductedSum < 0) {
        this.deductedSum = 0
      }
    }
  }

  def getJson: JsObject = {
    Json.obj(
      "sum" -> this.getSum,
      "deductedSum" -> this.getDeductedSum,
      "earnedIncomeAllowance" -> this.getIncomeDeduction,
      "basicDeduction" -> this.getExtraIncomeDeduction,
      "totalDeduction" -> this.getTotalTaxDeduction,
      "deductedSalary" -> this.getDeductedSalary
    )
  }
}