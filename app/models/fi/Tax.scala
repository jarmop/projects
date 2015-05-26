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
  private val medicalCareInsurancePayment = new MedicalCareInsurancePayment(this.municipalityTax.getDeductedSalary())
  private val churchTax = new ChurchTax(salary, municipality, this.municipalityTax.getTotalTaxDeduction)


  def getTotalTax: Double = {
    if (this.totalTax < 0)
      this.totalTax = this.calculateTotalTax

    this.totalTax
  }

  /**
   * All taxes minus workincomeDeduction
   */
  private def calculateTotalTax: Double = {
    var totalTax = this.governmentTax.getTax - this.getWorkIncomeDeduction
    if (totalTax >= 0) {
      totalTax += this.municipalityTax.getTax + this.getMedicalCareInsurancePayment + this.getChurchTax
    } else {
      val leftOverWorkIncomeDeduction = - totalTax
      totalTax = 0
      var totalDeductableTax = this.municipalityTax.getTax + this.getMedicalCareInsurancePayment + this.getChurchTax
      var deductedMunicipalityTax = this.municipalityTax.getTax - this.municipalityTax.getTax / totalDeductableTax * leftOverWorkIncomeDeduction
      deductedMunicipalityTax = if (deductedMunicipalityTax > 0) deductedMunicipalityTax else 0
      var deductedMedicalCareInsurancePayment = this.getMedicalCareInsurancePayment - this.getMedicalCareInsurancePayment / totalDeductableTax * leftOverWorkIncomeDeduction
      deductedMedicalCareInsurancePayment = if (deductedMedicalCareInsurancePayment > 0)  deductedMedicalCareInsurancePayment else 0
      var deductedChurchTax = this.getChurchTax - this.getChurchTax / totalDeductableTax * leftOverWorkIncomeDeduction
      deductedChurchTax = if (deductedChurchTax > 0)  deductedChurchTax else 0
      totalTax += deductedMunicipalityTax + deductedMedicalCareInsurancePayment + deductedChurchTax
    }
    totalTax += this.getPerDiemPayment + this.getYleTax

    totalTax
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
    this.getGovernmentTax / this.salary
  }

  def getMunicipalityTax: Double = {
    this.municipalityTax.getTax
  }

  def getMunicipalityTaxPercentage: Double = {
    this.getMunicipalityTax / this.salary
  }

  def getPerDiemPayment: Double = {
    this.perDiemPayment.getSum
  }

  def getPerDiemPaymentPercentage: Double = {
    this.getPerDiemPayment / this.salary
  }

  def getMedicalCareInsurancePayment: Double = {
    this.medicalCareInsurancePayment.getSum
  }

  def getMedicalCareInsurancePaymentPercentage: Double = {
    this.medicalCareInsurancePayment.getSum / this.salary
  }

  def getYleTax: Double = {
    this.YLETax.getTax
  }

  def getYleTaxPercentage: Double = {
    this.YLETax.getTax / this.salary
  }

  def getPensionContribution: Double = {
    this.pensionContribution.getSum
  }

  def getPensionContributionPercentage: Double = {
    this. getPensionContribution / this.salary
  }

  def getUnemploymentInsurance: Double = {
    this.unemploymentInsurance.getSum
  }

  def getUnemploymentInsurancePercentage: Double = {
    this.getUnemploymentInsurance / this.salary
  }

  def getChurchTax: Double = {
    this.churchTax.getSum
  }

  def getChurchTaxPercentage: Double = {
    this.churchTax.getSum / this.salary
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