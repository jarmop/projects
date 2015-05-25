package models.fi

import play.api.libs.json.{Json, Writes}

case class Tax(salary: Int, municipality: String, age: Int) {
  private val incomeDeduction: Double = 62000
  private val unemploymentInsurancePercent = 0.0065


  private var totalTax: Double = -1
  private var churchTax: Double = -1
  private var naturalSalary: Double = -1
  private var workIncomeDeduction: Double = -1

  private val perDiemPayment = new PerDiemPayment(salary)
  private val pensionContribution = new PensionContribution(salary, age)

  private var commonDeduction = Map[String, Double](
    "incomeDeduction" -> this.incomeDeduction,
    "pensionContribution" -> this.getPensionContribution,
    "unemploymentInsurance" -> this.getUnemploymentInsurance,
    "perDiemPayments" -> this.getPerDiemPayment
  )
  commonDeduction += "total" -> commonDeduction.foldLeft(0.0){  case (a, (k, v)) => a+v  }

  private val governmentTax: GovernmentTax = GovernmentTax(salary, this.incomeDeduction, this.commonDeduction.get("total").get)
  private val municipalityTax: MunicipalityTax = MunicipalityTax(salary, municipality, age, this.incomeDeduction, this.commonDeduction.get("total").get)
  private val YLETax: YLETax = new YLETax(salary, this.incomeDeduction)
  private val medicalCareInsurancePayment = new MedicalCareInsurancePayment(this.municipalityTax.getDeductedSalary())



  private def getChurchTax: Double = {
    if (this.churchTax < 0)
      this.churchTax = 0 // TODO calculate actual church tax

    this.churchTax
  }

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

  def getGovernmentTaxPercent: Double = {
    this.getGovernmentTax / this.salary
  }

  def getMunicipalityTax: Double = {
    this.municipalityTax.getTax
  }

  def getMunicipalityTaxPercent: Double = {
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
    this.salary * this.unemploymentInsurancePercent
  }

  def getUnemploymentInsurancePercent: Double = {
    this.getUnemploymentInsurance / this.salary
  }
}

object Tax {
  implicit val taxWrites = new Writes[Tax] {
    def writes(tax: Tax) = Json.obj(
      "municipalityTax" -> Json.toJson(tax.municipalityTax),
      "governmentTax" -> Json.toJson(tax.governmentTax),
      "yleTax" -> tax.YLETax.getJson,
      "medicalCareInsurancePayment" -> tax.medicalCareInsurancePayment.getJson,
      "perDiemPayment" -> tax.perDiemPayment.getJson,
      "commonDeduction" -> tax.commonDeduction,
      "totalTax" -> tax.getTotalTax,
      "workIncomeDeduction" -> tax.getWorkIncomeDeduction,
      "pensionContribution" -> tax.pensionContribution.getJson,
      "unemploymentInsurance" -> Json.obj(
        "percent" -> tax.unemploymentInsurancePercent,
        "sum" -> tax.commonDeduction.get("unemploymentInsurance").get
      )
    )
  }
}