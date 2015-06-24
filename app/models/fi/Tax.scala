package models.fi

import models._
import play.api.Logger
import play.api.libs.json.{JsObject, Json}
import services.Data

import scala.collection.mutable.ListBuffer

class Tax(earnedIncome: Double, municipality: String = "Helsinki", age: Int = 30) extends AbstractTax(earnedIncome) with TaxTrait {
  private val incomeDeduction: Double = 620

  private var totalTax: Double = -1
  private var naturalSalary: Double = -1
  private var workIncomeDeduction: Double = -1

  private val pensionContribution = new PensionContribution(earnedIncome, age)
  private val unemploymentInsurance = new UnemploymentInsurance(earnedIncome)
  private val perDiemPayment = new PerDiemPayment(earnedIncome)

  private var commonDeduction = Map[String, Double](
    "incomeDeduction" -> this.incomeDeduction,
    "pensionContribution" -> this.getPensionContribution,
    "unemploymentInsurance" -> this.getUnemploymentInsurance,
    "perDiemPayments" -> this.getPerDiemPayment
  )
  commonDeduction += "total" -> commonDeduction.foldLeft(0.0){  case (a, (k, v)) => a+v  }

  private val governmentTax: GovernmentTax = new GovernmentTax(earnedIncome, this.incomeDeduction, this.commonDeduction.get("total").get)
  private val municipalityTax: MunicipalityTax = new MunicipalityTax(earnedIncome, municipality, age, this.incomeDeduction, this.commonDeduction.get("total").get)
  private val yleTax: YLETax = new YLETax(earnedIncome, this.incomeDeduction)
  private val medicalCareInsurancePayment = new MedicalCareInsurancePayment(this.municipalityTax.getDeductedSalary)
  private val churchTax = new ChurchTax(earnedIncome, municipality, this.municipalityTax.getTotalTaxDeduction)

  this.reduceWorkIncomeDeduction

  val values = List[TaxValue](
    TaxValue(UnemploymentInsurance.name, this.getUnemploymentInsurance, this.getUnemploymentInsurancePercentage),
    TaxValue(PensionContribution.name, this.getPensionContribution, this.getPensionContributionPercentage),
    TaxValue(PerDiemPayment.name, this.getPerDiemPayment, this.getPerDiemPaymentPercentage),
    TaxValue(MedicalCareInsurancePayment.name, this.getMedicalCareInsurancePayment, this.getMedicalCareInsurancePaymentPercentage),
    TaxValue(YLETax.name, this.getYleTax, this.getYleTaxPercentage),
    TaxValue(ChurchTax.name, this.getChurchTax, this.getChurchTaxPercentage),
    TaxValue(MunicipalityTax.name, this.getMunicipalityTax, this.getMunicipalityTaxPercentage),
    TaxValue(GovernmentTax.name, this.getGovernmentTax, this.getGovernmentTaxPercentage)
  )

  def getTotalTax: Double = {
    if (this.totalTax < 0)
      this.totalTax = this.calculateTotalTax

    this.totalTax
  }

  def getTotalTaxPercentage: Double = {
    if (this.earnedIncome > 0) this.getTotalTax / this.earnedIncome else 0
  }

  private def calculateTotalTax: Double = {
    this.governmentTax.getDeductedSum + this.municipalityTax.getDeductedSum + this.medicalCareInsurancePayment.getDeductedSum + this.churchTax.getDeductedSum + this.getPerDiemPayment + this.getYleTax + this.getUnemploymentInsurance + this.getPensionContribution
  }

  private def reduceWorkIncomeDeduction = {
    this.governmentTax.reduceWorkIncomeDeduction(this.getWorkIncomeDeduction)
    var totalDeductableTax = this.municipalityTax.getSum + this.medicalCareInsurancePayment.getSum + this.churchTax.getSum
    this.municipalityTax.reduceWorkIncomeDeduction(totalDeductableTax, this.governmentTax.getLeftOverWorkIncomeDeduction)
    this.medicalCareInsurancePayment.reduceWorkIncomeDeduction(totalDeductableTax, this.governmentTax.getLeftOverWorkIncomeDeduction)
    this.churchTax.reduceWorkIncomeDeduction(totalDeductableTax, this.governmentTax.getLeftOverWorkIncomeDeduction)
    // update total tax?
  }

  private def updateTotalTax = {
    this.totalTax = this.calculateTotalTax
  }

  def getWorkIncomeDeduction: Double = {
    if (this.workIncomeDeduction < 0)
      this.workIncomeDeduction = this.calculateWorkIncomeDeduction

    this.workIncomeDeduction
  }

  def getWorkIncomeDeductionPercentage: Double = {
    if (this.earnedIncome > 0) this.getWorkIncomeDeduction / this.earnedIncome else 0
  }

  private def calculateWorkIncomeDeduction: Double = {
    var deduction: Double = 0
    if (this.earnedIncome > 2500) {
      deduction = 0.086 * (this.earnedIncome - 2500)
    }
    var maxDeduction: Double = 1025
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
      this.naturalSalary = this.earnedIncome - this.incomeDeduction

    this.naturalSalary
  }

  def getGovernmentTax: Double = {
    this.governmentTax.getDeductedSum
  }

  def getGovernmentTaxPercentage: Double = {
    if (this.earnedIncome > 0) this.getGovernmentTax / this.earnedIncome else 0
  }

  def getMunicipalityTax: Double = {
    this.municipalityTax.getDeductedSum
  }

  def getMunicipalityTaxPercentage: Double = {
    if (this.earnedIncome > 0) this.getMunicipalityTax / this.earnedIncome else 0
  }

  def getPerDiemPayment: Double = {
    this.perDiemPayment.getSum
  }

  def getPerDiemPaymentPercentage: Double = {
    if (this.earnedIncome > 0) this.getPerDiemPayment / this.earnedIncome else 0
  }

  def getMedicalCareInsurancePayment: Double = {
    this.medicalCareInsurancePayment.getDeductedSum
  }

  def getMedicalCareInsurancePaymentPercentage: Double = {
    if (this.earnedIncome > 0) this.getMedicalCareInsurancePayment / this.earnedIncome else 0
  }

  def getYleTax: Double = {
    this.yleTax.getSum
  }

  def getYleTaxPercentage: Double = {
    if (this.earnedIncome > 0) this.getYleTax / this.earnedIncome else 0
  }

  def getPensionContribution: Double = {
    this.pensionContribution.getSum
  }

  def getPensionContributionPercentage: Double = {
    if (this.earnedIncome > 0) this.getPensionContribution / this.earnedIncome else 0
  }

  def getUnemploymentInsurance: Double = {
    this.unemploymentInsurance.getSum
  }

  def getUnemploymentInsurancePercentage: Double = {
    if (this.earnedIncome > 0) this.getUnemploymentInsurance / this.earnedIncome else 0
  }

  def getChurchTax: Double = {
    this.churchTax.getDeductedSum
  }

  def getChurchTaxPercentage: Double = {
    if (this.earnedIncome > 0) this.getChurchTax / this.earnedIncome else 0
  }

  def getNetIncome: Double = {
    this.earnedIncome - this.getTotalTax
  }

  def getJson: JsObject = {
    Json.obj(
      "taxes" -> Json.obj(
        "municipalityTax" -> this.municipalityTax.getJson,
        "governmentTax" -> this.governmentTax.getJson,
        "YLETax" -> this.yleTax.getJson,
        "medicalCareInsurancePayment" -> this.medicalCareInsurancePayment.getJson,
        "perDiemPayment" -> this.perDiemPayment.getJson,
        "pensionContribution" -> this.pensionContribution.getJson,
        "unemploymentInsurance" -> this.unemploymentInsurance.getJson,
        "churchTax" -> this.churchTax.getJson
      ),
      "commonDeduction" -> this.commonDeduction,
      "workIncomeDeduction" -> this.getWorkIncomeDeduction,
      "totalTax" -> this.getTotalTax,
      "totalTaxPercentage" -> this.getTotalTaxPercentage,
      "netIncome" -> this.getNetIncome
    )
  }
}

object Tax extends TaxObjectTrait{
  protected val valueNames = List[String](
    UnemploymentInsurance.name,
    PensionContribution.name,
    PerDiemPayment.name,
    MedicalCareInsurancePayment.name,
    YLETax.name,
    ChurchTax.name,
    MunicipalityTax.name,
    GovernmentTax.name
  )
}