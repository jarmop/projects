package models.sv

trait SwedishTax {
  def getTotalTax: Double
  def getTotalTaxPercentage: Double
  def getNetIncome: Double
  def getStateTax: Double
  def getStateTaxPercentage: Double
  def getMunicipalityTax: Double
  def getMunicipalityTaxPercentage: Double
  def getCountyTax: Double
  def getCountyTaxPercentage: Double
  def getChurchPayment: Double
  def getChurchPaymentPercentage: Double
  def getFuneralPayment: Double
  def getFuneralPaymentPercentage: Double
  def getPensionContribution: Double
  def getPensionContributionPercentage: Double
  def getTaxCredit: Double
  def getTaxCreditPercentage: Double
}
