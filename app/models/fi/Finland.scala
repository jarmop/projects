package models.fi

import models.{TaxObjectTrait, CountryTrait, TaxTrait}

object Finland extends CountryTrait {
  def getCountryCode: String = "fi"
  def getName: String = "Suomi"

  def getTax(earnedIncome: Double): TaxTrait = {
    new Tax(earnedIncome)
  }

  def getTax: TaxObjectTrait = {
    Tax
  }
}
