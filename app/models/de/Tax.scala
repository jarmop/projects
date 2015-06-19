package models.de

import models._
import play.api.libs.json.{Json, JsObject}
import services._

import scala.collection.mutable.ListBuffer

class Tax(earnedIncome: Double, municipality: String = "Berlin", age: Int = 30) extends AbstractTax(earnedIncome) with models.TaxTrait {
  val basicAllowance = 1000
  val socialSecurity = new SocialSecurity(earnedIncome)
  val incomeTax = new IncomeTax(earnedIncome, (this.getIncomeTaxDeductions + this.basicAllowance))
  val solidaritySurcharge = new SolidaritySurcharge(this.getIncomeTax)
  val churchTax = new ChurchTax(this.getIncomeTax)

  def getIncomeTaxDeductions: Double = {
    this.socialSecurity.getSum
  }

  def getIncomeTax: Double = {
    this.incomeTax.getSum
  }

  def getIncomeTaxPercentage: Double = {
   this.getPercentage(this.getIncomeTax)
  }

  def getSolidaritySurcharge: Double = {
    this.solidaritySurcharge.getSum
  }

  def getSolidaritySurchargePercentage: Double = {
    this.getPercentage(this.getSolidaritySurcharge)
  }

  def getChurchTax: Double = {
    this.churchTax.getSum
  }

  def getChurchTaxPercentage: Double = {
    this.getPercentage(this.getChurchTax)
  }

  def getSocialSecurity: Double = {
    this.socialSecurity.getSum
  }

  def getSocialSecurityPercentage: Double = {
    this.getPercentage(this.getSocialSecurity)
  }

  def getPensionIncurance: Double = {
    this.socialSecurity.getPensionInsurance
  }

  def getPensionIncurancePercentage: Double = {
    this.getPercentage(this.getPensionIncurance)
  }

  def getUnemploymentInsurance: Double = {
    this.socialSecurity.getUnemploymentInsurance
  }

  def getUnemploymentInsurancePercentage: Double = {
    this.getPercentage(this.getUnemploymentInsurance)
  }

  def getNursingInsurance: Double = {
    this.socialSecurity.getNursingInsurance
  }

  def getNursingInsurancePercentage: Double = {
    this.getPercentage(this.getNursingInsurance)
  }

  def getHealthInsurance: Double = {
    this.socialSecurity.getHealthInsurance + this.socialSecurity.getAdditionalHealthInsurance
  }

  def getHealthInsurancePercentage: Double = {
    this.getPercentage(this.getHealthInsurance)
  }

  def getTotalTax: Double = {
    this.getIncomeTax + this.getSolidaritySurcharge + this.getChurchTax + this.getSocialSecurity
  }

  def getTotalTaxPercentage: Double = {
    this.getPercentage(this.getTotalTax)
  }

  def getNetIncome: Double = {
    this.earnedIncome - this.getTotalTax
  }

  def getJson: JsObject = {
    Json.obj(
      "taxes" -> Json.obj(
        "incomeTax" -> this.incomeTax.getJson,
        "solidaritySurcharge" -> this.solidaritySurcharge.getJson,
        "churchTax" -> this.churchTax.getJson,
        "socialSecurity" -> this.socialSecurity.getJson
      ),
      "totalTax" -> this.getTotalTax,
      "totalTaxPercentage" -> this.getTotalTaxPercentage,
      "netIncome" -> this.getNetIncome
    )
  }

  def getSubTaxByName(subTaxName: String): SubTaxTrait = subTaxName match {
    case ChurchTax.name => this.churchTax
  }
}

object Tax extends TaxObjectTrait{
  def getDataList: List[Data] = {
    List(
      Data(ChurchTax.name, new ListBuffer[List[Double]])
    )
  }
}