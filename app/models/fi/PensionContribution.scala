package models.fi

import models.{SubTaxTrait, SubTaxObjectTrait}
import play.api.libs.json.{Json, JsObject}

class PensionContribution(earnedIncome: Double, age: Int) extends SubTaxTrait {
  private val pensionContributionTyelSub53Percent = 0.057
  private val pensionContributionTyel53Percent = 0.072

  private def getPensionContributionTyelPercent: Double = {
    if (this.age < 53) {
      return this.pensionContributionTyelSub53Percent;
    } else {
      return this.pensionContributionTyel53Percent;
    }
  }

  def getSum: Double = {
    this.earnedIncome * this.getPensionContributionTyelPercent
  }

  def getJson: JsObject = {
    Json.obj(
      "tyel53Percent" -> this.pensionContributionTyel53Percent,
      "tyelSub53Percent" -> this.pensionContributionTyelSub53Percent,
      "percent" -> this.getPensionContributionTyelPercent,
      "sum" -> this.getSum
    )
  }
}

object PensionContribution extends SubTaxObjectTrait {
  val name = "Työeläkemaksu"
}
