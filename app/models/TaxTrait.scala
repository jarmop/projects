package models

import play.api.libs.json.JsObject

trait TaxTrait {
  def getJson: JsObject
  def getTotalTax: Double
  def getTotalTaxPercentage: Double
  def getNetIncome: Double
  def getValues: List[TaxValue]
  def getValueByName(name: String): TaxValue
}