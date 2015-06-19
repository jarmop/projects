package models

trait CountryTrait {
  def getCountryCode: String
  def getName: String
  def getTax(earnedIncome: Double): TaxTrait
  def getTax: TaxObjectTrait
}
