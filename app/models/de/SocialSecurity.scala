package models.de

import play.api.libs.json.{Json, JsObject}
import scala.math.min

class SocialSecurity(earnedIncome: Double) {
  val pensionInsurancePercent: Double = 0.0935
  val unemploymentInsurancePercent: Double = 0.015
  val nursingInsurancePercent: Double = 0.01425 // for childless individual over 23, otherwise 0.01175
  val healthInsurancePercent: Double = 0.073
  val additionalHealthInsurancePercent: Double = 0.009 // Average. Depends on insurance provider.

  var pensionInsurance: Double = -1

  def getPensionInsurance: Double = {
    this.pensionInsurancePercent * min(this.earnedIncome, 62400)
  }

  def getUnemploymentInsurance: Double = {
    this.unemploymentInsurancePercent * min(this.earnedIncome, 62400)
  }

  def getNursingInsurance: Double = {
    this.nursingInsurancePercent * min(this.earnedIncome, 49500)
  }

  def getHealthInsurance: Double = {
    this.healthInsurancePercent * min(this.earnedIncome, 49500)
  }

  def getAdditionalHealthInsurance: Double = {
    this.additionalHealthInsurancePercent * min(this.earnedIncome, 49500)
  }

  def getSum: Double = {
    this.getPensionInsurance + this.getUnemploymentInsurance + this.getNursingInsurance + this.getHealthInsurance + this.getAdditionalHealthInsurance
  }

  def getJson: JsObject = Json.obj(
    "pensionInsurance" -> this.getPensionInsurance,
    "unemploymentInsurance" -> this.getUnemploymentInsurance,
    "nursingInsurance" -> this.getNursingInsurance,
    "healthInsurance" -> this.getHealthInsurance,
    "additionalHealthInsurance" -> this.getAdditionalHealthInsurance,
    "sum" -> this.getSum
  )
}
