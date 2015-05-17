package models

import play.api.libs.json.{Json, Writes}

case class Tax(salary: Int, municipality: String, age: Int) {
  private val incomeDeduction: Double = 62000
  private val pensionContributionTyelSub53Percent = 0.057
  private val pensionContributionTyel53Percent = 0.072
  private val unemploymentInsurancePercent = 0.0065
  private val perDiemPaymentsTyelPercent = 0.0078
  private val yleTaxPercent = 0.0068
  private val medicalCareInsurancePercent = 0.0132

  private var yleSalary: Double = -1

  private var commonDeduction = Map[String, Double](
    "incomeDeduction" -> this.incomeDeduction,
    "pensionContribution" -> this.salary * this.getPensionContributionTyelPercent(),
    "unemploymentInsurance" -> this.salary * this.unemploymentInsurancePercent,
    "perDiemPayments" -> this.getPerDiemPayments
  )
  commonDeduction += "total" -> commonDeduction.foldLeft(0.0){  case (a, (k, v)) => a+v  }

  private val governmentTax: GovernmentTax = GovernmentTax(salary, this.incomeDeduction, this.commonDeduction.get("total").get)
  private val municipalityTax: MunicipalityTax = MunicipalityTax(salary, municipality, age, this.incomeDeduction, this.commonDeduction.get("total").get)

  private def getPensionContributionTyelPercent(): Double = {
    if (this.age < 53) {
      return this.pensionContributionTyelSub53Percent;
    } else {
      return this.pensionContributionTyel53Percent;
    }
  }

  private def getPerDiemPayments: Double = {
    this.salary * this.perDiemPaymentsTyelPercent
  }

  private def getMedicalCareInsurancePayment: Double = {
    this.municipalityTax.getDeductedSalary * this.medicalCareInsurancePercent
  }

  private def getYleTaxDeduction: Double = {
    return this.incomeDeduction
  }

  private def getYleSalary: Double = {
    if (this.yleSalary < 0)
      this.yleSalary = this.salary - this.getYleTaxDeduction

    this.yleSalary
  }

  private def getYleTax: Double = {
    var salary = this.getYleSalary

    if (salary < 750000) {
      0
    }
    if (salary >= 2102900) {
      14300
    }

    return salary * this.yleTaxPercent;
  }

  private def getTotalTax(): Double = {
    return this.municipalityTax.getTax() + this.governmentTax.getTax() + this.getMedicalCareInsurancePayment + this.getPerDiemPayments + this.getYleTax
  }
}

object Tax {
  implicit val taxWrites = new Writes[Tax] {
    def writes(tax: Tax) = Json.obj(
      "municipalityTax" -> Json.toJson(tax.municipalityTax),
      "governmentTax" -> Json.toJson(tax.governmentTax),
      "yleTax" -> tax.getYleTax,
      "medicalCareInsurancePayment" -> tax.getMedicalCareInsurancePayment,
      "perDiemPayments" -> tax.getPerDiemPayments,
      "commonDeduction" -> tax.commonDeduction,
      "totalTax" -> tax.getTotalTax()
    )
  }
}