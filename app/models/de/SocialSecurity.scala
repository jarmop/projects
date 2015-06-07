package models.de

import play.api.libs.json.{Json, JsObject}

class SocialSecurity(earnedIncome: Double) {
  val pensionInsurancePercent: Double = 0.0935
  val unemploymentInsurancePercent: Double = 0.015
  val nursingInsurancePercent: Double = 0.01425 // for childless individual over 23, otherwise 0.01175
  val healthInsurancePercent: Double = 0.073
  val additionalHealthInsurancePercent: Double = 0.009 // Average. Depends on insurance provider.

  def getPensionInsurance: Double = {
    this.pensionInsurancePercent * this.earnedIncome
  }

  def getUnemploymentInsurance: Double = {
    this.unemploymentInsurancePercent * this.earnedIncome
  }

  def getNursingInsurance: Double = {
    this.nursingInsurancePercent * this.earnedIncome
  }

  def getHealthInsurance: Double = {
    this.healthInsurancePercent * this.earnedIncome
  }

  def getAdditionalHealthInsurance: Double = {
    this.additionalHealthInsurancePercent * this.earnedIncome
  }

  def getSum: Double = {
    this.getPensionInsurance + this.getUnemploymentInsurance + this.getNursingInsurance + this.getHealthInsurance + this.getAdditionalHealthInsurance
  }

  def getJson: JsObject = Json.obj(
    "pensionInsurance" -> this.getPensionInsurance,
    "unemploymentInsurance" -> this.getUnemploymentInsurance,
    "nursingInsurance" -> this.getNursingInsurance,
    "healthInsurance" -> this.getHealthInsurance,
    "additionalHealthInsurance" -> this.getAdditionalHealthInsurance
  )
}
