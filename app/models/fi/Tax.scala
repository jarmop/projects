package models.fi

import play.api.Logger
import play.api.libs.json.{JsObject, Json}

class Tax(salary: Int, municipality: String, age: Int) {
  private val incomeDeduction: Double = 62000

  private var totalTax: Double = -1
  private var naturalSalary: Double = -1
  private var workIncomeDeduction: Double = -1

  private val pensionContribution = new PensionContribution(salary, age)
  private val unemploymentInsurance = new UnemploymentInsurance(salary)
  private val perDiemPayment = new PerDiemPayment(salary)

  private var commonDeduction = Map[String, Double](
    "incomeDeduction" -> this.incomeDeduction,
    "pensionContribution" -> this.getPensionContribution,
    "unemploymentInsurance" -> this.getUnemploymentInsurance,
    "perDiemPayments" -> this.getPerDiemPayment
  )
  commonDeduction += "total" -> commonDeduction.foldLeft(0.0){  case (a, (k, v)) => a+v  }

  private val governmentTax: GovernmentTax = new GovernmentTax(salary, this.incomeDeduction, this.commonDeduction.get("total").get)
  private val municipalityTax: MunicipalityTax = new MunicipalityTax(salary, municipality, age, this.incomeDeduction, this.commonDeduction.get("total").get)
  private val YLETax: YLETax = new YLETax(salary, this.incomeDeduction)
  private val medicalCareInsurancePayment = new MedicalCareInsurancePayment(this.municipalityTax.getDeductedSalary)
  private val churchTax = new ChurchTax(salary, municipality, this.municipalityTax.getTotalTaxDeduction)

  this.reduceWorkIncomeDeduction

  def getTotalTax: Double = {
    if (this.totalTax < 0)
      this.totalTax = this.calculateTotalTax

    this.totalTax
  }

  private def calculateTotalTax: Double = {
    this.governmentTax.getDeductedSum + this.municipalityTax.getDeductedSum + this.medicalCareInsurancePayment.getDeductedSum + this.churchTax.getDeductedSum + this.getPerDiemPayment + this.getYleTax
  }

  private def reduceWorkIncomeDeduction = {
    this.governmentTax.reduceWorkIncomeDeduction(this.getWorkIncomeDeduction)
    var totalDeductableTax = this.municipalityTax.getSum + this.medicalCareInsurancePayment.getSum + this.churchTax.getSum
    this.municipalityTax.reduceWorkIncomeDeduction(totalDeductableTax, this.governmentTax.getLeftOverWorkIncomeDeduction)
    this.medicalCareInsurancePayment.reduceWorkIncomeDeduction(totalDeductableTax, this.governmentTax.getLeftOverWorkIncomeDeduction)
    this.churchTax.reduceWorkIncomeDeduction(totalDeductableTax, this.governmentTax.getLeftOverWorkIncomeDeduction)
  }

  private def getWorkIncomeDeduction: Double = {
    if (this.workIncomeDeduction < 0)
      this.workIncomeDeduction = this.calculateWorkIncomeDeduction

    this.workIncomeDeduction
  }

  private def calculateWorkIncomeDeduction: Double = {
    var deduction: Double = 0
    if (this.salary > 250000) {
      deduction = 0.086 * (this.salary - 250000)
    }
    var maxDeduction: Double = 102500
    if (deduction > maxDeduction) {
      deduction = maxDeduction
    }
    if (this.getNaturalSalary > 3300000) {
      deduction = deduction - (0.012 * (this.getNaturalSalary - 3300000))
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

  def getGovernmentTax: Double = {
    this.governmentTax.getTax
  }

  def getGovernmentTaxPercentage: Double = {
    if (this.salary > 0) this.getGovernmentTax / this.salary else 0
  }

  def getMunicipalityTax: Double = {
    this.municipalityTax.getDeductedSum
  }

  def getMunicipalityTaxPercentage: Double = {
    if (this.salary > 0) this.getMunicipalityTax / this.salary else 0
  }

  def getPerDiemPayment: Double = {
    this.perDiemPayment.getSum
  }

  def getPerDiemPaymentPercentage: Double = {
    if (this.salary > 0) this.getPerDiemPayment / this.salary else 0
  }

  def getMedicalCareInsurancePayment: Double = {
    this.medicalCareInsurancePayment.getDeductedSum
  }

  def getMedicalCareInsurancePaymentPercentage: Double = {
    if (this.salary > 0) this.getMedicalCareInsurancePayment / this.salary else 0
  }

  def getYleTax: Double = {
    this.YLETax.getTax
  }

  def getYleTaxPercentage: Double = {
    if (this.salary > 0) this.getYleTax / this.salary else 0
  }

  def getPensionContribution: Double = {
    this.pensionContribution.getSum
  }

  def getPensionContributionPercentage: Double = {
    if (this.salary > 0) this.getPensionContribution / this.salary else 0
  }

  def getUnemploymentInsurance: Double = {
    this.unemploymentInsurance.getSum
  }

  def getUnemploymentInsurancePercentage: Double = {
    if (this.salary > 0) this.getUnemploymentInsurance / this.salary else 0
  }

  def getChurchTax: Double = {
    this.churchTax.getDeductedSum
  }

  def getChurchTaxPercentage: Double = {
    if (this.salary > 0) this.getChurchTax / this.salary else 0
  }

  def getJson: JsObject = {
    Json.obj(
      "municipalityTax" -> this.municipalityTax.getJson,
      "governmentTax" -> this.governmentTax.getJson,
      "YLETax" -> this.YLETax.getJson,
      "medicalCareInsurancePayment" -> this.medicalCareInsurancePayment.getJson,
      "perDiemPayment" -> this.perDiemPayment.getJson,
      "commonDeduction" -> this.commonDeduction,
      "totalTax" -> this.getTotalTax,
      "workIncomeDeduction" -> this.getWorkIncomeDeduction,
      "pensionContribution" -> this.pensionContribution.getJson,
      "unemploymentInsurance" -> this.unemploymentInsurance.getJson,
      "churchTax" -> this.churchTax.getJson
    )
  }
}