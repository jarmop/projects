package models.sv

import models.{CountryTrait, TaxTrait}

object Sweden extends CountryTrait {
  def getCountryCode: String = "sv"
  def getName: String = "Ruotsi"

  def getTax(earnedIncome: Double): TaxTrait = {
    new TaxEuro(earnedIncome)
  }
}