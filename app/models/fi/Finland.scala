package models.fi

import models.{CountryTrait, TaxTrait}

object Finland extends CountryTrait {
  def getCountryCode: String = "fi"
  def getName: String = "Suomi"

  def getTax(earnedIncome: Double): TaxTrait = {
    new Tax(earnedIncome)
  }
}
