package models.de

import models.{CountryTrait, TaxTrait}

object Germany extends CountryTrait {
  def getCountryCode: String = "de"
  def getName: String = "Saksa"

  def getTax(earnedIncome: Double): TaxTrait = {
    new Tax(earnedIncome)
  }
}
