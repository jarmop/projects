package models

import play.api.libs.json.{Json, Writes}
import scala.collection.mutable.ListBuffer
import scala.util.control.Breaks._

case class GovernmentTax(salary: Int, naturalDeduction: Double, commonDeduction: Double) {
  var tax: Double = -1
  var taxSectionHits = new ListBuffer[Map[String, Double]]

  def getTax: Double = {
    if (this.tax < 0)
      this.tax = this.calculateTax

    this.tax
  }

  private def calculateTax: Double = {
    var tax: Double = if (this.salary < 1650000) 0 else 800

    val governmentTaxList = List[Map[String, Double]](
      Map[String, Double]("minSalary" -> 1650000, "maxSalary" -> 2470000, "taxPercent" -> 0.065),
      Map[String, Double]("minSalary" -> 2470000, "maxSalary" -> 4030000, "taxPercent" -> 0.175),
      Map[String, Double]("minSalary" -> 4030000, "maxSalary" -> 7140000, "taxPercent" -> 0.215),
      Map[String, Double]("minSalary" -> 7140000, "maxSalary" -> 9000000, "taxPercent" -> 0.2975),
      Map[String, Double]("minSalary" -> 9000000, "maxSalary" -> 0, "taxPercent" -> 0.3175)
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
}

object GovernmentTax {
  implicit val governmentWrites = new Writes[GovernmentTax] {
    def writes(governmentTax: GovernmentTax) = Json.obj(
      "sum" -> governmentTax.getTax,
      "deduction" -> governmentTax.getDeduction,
      "deductedSalary" -> governmentTax.getDeductedSalary,
      "hits" -> governmentTax.getTaxSectionHits
    )
  }
}
