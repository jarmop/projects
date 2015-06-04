package models.sv

trait SwedishTax {
  def getTotalTaxPercentage: Double
  def getTotalTax: Double
  def getNetIncome: Double
  def getStateTaxPercentage: Double
  def getMunicipalityTaxPercentage: Double
  def getCountyTaxPercentage: Double
  def getChurchPaymentPercentage: Double
  def getFuneralPaymentPercentage: Double
  def getPensionContributionPercentage: Double
  def getTaxCreditPercentage: Double
}
