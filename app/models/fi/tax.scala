package models.fi

import play.api.libs.json.{Json, Writes}

case class Tax(salary: Int, municipality: String, age: Int) {
  private val incomeDeduction: Double = 62000
  private val pensionContributionTyelSub53Percent = 0.057
  private val pensionContributionTyel53Percent = 0.072
  private val unemploymentInsurancePercent = 0.0065
  private val perDiemPaymentsTyelPercent = 0.0078
  private val medicalCareInsurancePercent = 0.0132


  private var totalTax: Double = -1
  private var churchTax: Double = -1
  private var naturalSalary: Double = -1
  private var workIncomeDeduction: Double = -1

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

  private def getPensionContributionTyelPercent: Double = {
    if (this.age < 53) {
      return this.pensionContributionTyelSub53Percent;
    } else {
      return this.pensionContributionTyel53Percent;
    }
  }

  def getPerDiemPayment: Double = {
    this.salary * this.perDiemPaymentsTyelPercent
  }

  def getMedicalCareInsurancePayment: Double = {
    this.municipalityTax.getDeductedSalary * this.medicalCareInsurancePercent
  }



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
    totalTax += this.getPerDiemPayment + this.YLETax.getTax

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

  def getPerDiemPaymentPercent: Double = {
    this.getPerDiemPayment / this.salary
  }

  def getMedicalCareInsurancePaymentPercent: Double = {
    this.getMedicalCareInsurancePayment / this.salary
  }

  def getYleTax: Double = {
    this.YLETax.getTax
  }

  def getYleTaxPercent: Double = {
    this.YLETax.getTax / this.salary
  }

  def getPensionContribution: Double = {
    this.salary * this.getPensionContributionTyelPercent
  }

  def getPensionContributionPercent: Double = {
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
      "medicalCareInsurancePayment" -> Json.obj(
        "percent" -> tax.medicalCareInsurancePercent,
        "sum" -> tax.getMedicalCareInsurancePayment
      ),
      "perDiemPayment" -> Json.obj(
        "percent" -> tax.perDiemPaymentsTyelPercent,
        "sum" -> tax.getPerDiemPayment
      ),
      "commonDeduction" -> tax.commonDeduction,
      "totalTax" -> tax.getTotalTax,
      "workIncomeDeduction" -> tax.getWorkIncomeDeduction,
      "pensionContribution" -> Json.obj(
        "tyel53Percent" -> tax.pensionContributionTyel53Percent,
        "tyelSub53Percent" -> tax.pensionContributionTyelSub53Percent,
        "percent" -> tax.getPensionContributionTyelPercent,
        "sum" -> tax.commonDeduction.get("pensionContribution").get
      ),
      "unemploymentInsurance" -> Json.obj(
        "percent" -> tax.unemploymentInsurancePercent,
        "sum" -> tax.commonDeduction.get("unemploymentInsurance").get
      )
    )
  }
}