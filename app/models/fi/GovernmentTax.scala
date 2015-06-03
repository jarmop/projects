package models.fi

import play.api.Logger
import play.api.libs.json.{JsObject, Json}
import scala.collection.mutable.ListBuffer
import scala.util.control.Breaks._

class GovernmentTax(salary: Int, naturalDeduction: Double, commonDeduction: Double) {
  var deductedSum: Double = 0
  var leftOverWorkIncomeDeduction: Double = 0
  var tax: Double = -1
  var taxSectionHits = new ListBuffer[Map[String, Double]]

  def reduceWorkIncomeDeduction(workIncomeDeduction: Double) = {
    this.deductedSum = this.getTax - workIncomeDeduction
    if (this.deductedSum < 0) {
      this.leftOverWorkIncomeDeduction = -this.deductedSum
      this.deductedSum = 0
    }
  }

  def getLeftOverWorkIncomeDeduction: Double = {
    this.leftOverWorkIncomeDeduction
  }

  def getDeductedSum: Double = {
    this.deductedSum
  }

  def getTax: Double = {
    if (this.tax < 0)
      this.tax = this.calculateTax

    this.tax
  }

  private def calculateTax: Double = {
    var tax: Double = if (this.salary < 16500) 0 else 8

    val governmentTaxList = List[Map[String, Double]](
      Map[String, Double]("minSalary" -> 16500, "maxSalary" -> 24700, "taxPercent" -> 0.065),
      Map[String, Double]("minSalary" -> 24700, "maxSalary" -> 40300, "taxPercent" -> 0.175),
      Map[String, Double]("minSalary" -> 40300, "maxSalary" -> 71400, "taxPercent" -> 0.215),
      Map[String, Double]("minSalary" -> 71400, "maxSalary" -> 90000, "taxPercent" -> 0.2975),
      Map[String, Double]("minSalary" -> 90000, "maxSalary" -> 0, "taxPercent" -> 0.3175)
    )

    this.taxSectionHits = new ListBuffer[Map[String, Double]]
    breakable { for (governmentTaxMap <- governmentTaxList) {
      var salary = this.getDeductedSalary
      if (salary < governmentTaxMap.get("minSalary").get)
        break

      if (governmentTaxMap.get("maxSalary").get > 0 && salary > governmentTaxMap.get("maxSalary").get)
        salary = governmentTaxMap.get("maxSalary").get

      var taxedSalary = salary - governmentTaxMap.get("minSalary").get;
      val sectionTax = taxedSalary * governmentTaxMap.get("taxPercent").get;

      tax += sectionTax;

      this.taxSectionHits.append(Map[String, Double](
        "tax" -> sectionTax,
        "taxedSalary" -> taxedSalary,
        "minSalary" -> governmentTaxMap.get("minSalary").get,
        "maxSalary" -> governmentTaxMap.get("maxSalary").get,
        "taxPercent" -> governmentTaxMap.get("taxPercent").get
      ))
    }}

    tax;
  }

  private def getDeductedSalary: Double = {
    this.salary - this.getDeduction
  }

  private def getDeduction: Double = {
    this.commonDeduction
  }

  private def getTaxSectionHits: ListBuffer[Map[String, Double]] = {
    if (this.taxSectionHits.isEmpty)
      this.getTax

    this.taxSectionHits
  }

  def getJson: JsObject = {
    Json.obj(
      "sum" -> this.getDeductedSum,
      "deduction" -> this.getDeduction,
      "deductedSalary" -> this.getDeductedSalary,
      "hits" -> this.getTaxSectionHits
    )
  }
}
