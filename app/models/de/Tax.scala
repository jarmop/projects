package models.de

import models.{AbstractTax, TaxTrait}
import play.api.libs.json.{Json, JsObject}
import services._

class Tax(earnedIncome: Double, municipality: String, age: Int) extends AbstractTax(earnedIncome) with models.TaxTrait {
  val basicAllowance = 1000
  val socialSecurity = new SocialSecurity(earnedIncome)
  val incomeTax = new IncomeTax(earnedIncome - (this.getIncomeTaxDeductions + this.basicAllowance))
//6145
  def getIncomeTaxDeductions: Double = {
    this.socialSecurity.getSum
  }

  def getIncomeTax: Double = {
    this.incomeTax.getSum
  }

  def getTotalTax: Double = {
    0
  }

  def getTotalTaxPercentage: Double = {
    0
  }

  def getJson: JsObject = {
    Json.obj(
      "incomeTax" -> this.incomeTax.getJson,
      "socialSecurity" -> this.socialSecurity.getJson,
      "totalTax" -> this.getTotalTax,
      "totalTaxPercentage" -> this.getTotalTaxPercentage
    )
  }
}