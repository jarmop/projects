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
  private var totalTax: Double = -1
  private var churchTax: Double = -1
  private var naturalSalary: Double = -1

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
      return 0
    }
    if (salary >= 2102900) {
      return 14300
    }

    return salary * this.yleTaxPercent;
  }

  private def getChurchTax: Double = {
    if (this.churchTax < 0)
      this.churchTax = 0 // TODO calculate actual church tax

    this.churchTax
  }

  private def getTotalTax(): Double = {
    if (this.totalTax < 0)
      this.totalTax = this.calculateTotalTax()

    this.totalTax
  }

  /**
   * All taxes minus workincomeDeduction
   */
  private def calculateTotalTax(): Double = {
    var deductedGovernmentTax = this.governmentTax.getTax() - this.getWorkIncomeDeduction()
    var leftOverWorkIncomeDeduction: Double = 0
    if (deductedGovernmentTax < 0) {
      leftOverWorkIncomeDeduction = - deductedGovernmentTax
      deductedGovernmentTax = 0
    }

    var totalTax: Double = 0
    if (leftOverWorkIncomeDeduction == 0) {
      totalTax = deductedGovernmentTax + this.municipalityTax.getTax + this.getMedicalCareInsurancePayment + this.getChurchTax + this.getPerDiemPayments + this.getYleTax
    } else {
      var totalDeductableTax = this.municipalityTax.getTax + this.getMedicalCareInsurancePayment + this.getChurchTax
      var deductedMunicipalityTax = this.municipalityTax.getTax - this.municipalityTax.getTax / totalDeductableTax * this.municipalityTax.getTax
      var deductedMedicalCareInsurancePayment = this.getMedicalCareInsurancePayment - this.getMedicalCareInsurancePayment / totalDeductableTax * this.getMedicalCareInsurancePayment
      var deductedChurchTax = this.getChurchTax - this.getChurchTax / totalDeductableTax * this.getChurchTax
      totalTax = deductedGovernmentTax + deductedMunicipalityTax + deductedMedicalCareInsurancePayment + deductedChurchTax + this.getPerDiemPayments + this.getYleTax
    }

    totalTax
  }

  private def getWorkIncomeDeduction(): Double = {
    var deduction: Double = 0
    if (this.salary > 250000) {
      deduction = 0.086 * (this.salary - 250000)
    }

    var maxDeduction: Double = 102500
    if (deduction > maxDeduction) {
      deduction = maxDeduction
    }

    if (this.getNaturalSalary > 33000) {
      deduction = deduction - (0.012 * (this.getNaturalSalary - 33000))
    }

    if (deduction < 0) {
      deduction = 0
    }

    deduction
  }

  private def getNaturalSalary: Double = {
    if (this.naturalSalary < 0)
      this.naturalSalary = this.salary - this.incomeDeduction

    this.naturalSalary
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