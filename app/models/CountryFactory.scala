package models

import models.de.Germany
import models.fi.Finland
import models.sv.Sweden

object CountryFactory {
  val countryMap = Map[String, CountryTrait](
    Finland.getCountryCode -> Finland,
    Sweden.getCountryCode -> Sweden,
    Germany.getCountryCode -> Germany
  )

  def getCountryCodes: Iterable[String] = {
    countryMap.keys
  }

  def getCountries: Iterable[CountryTrait] = {
    countryMap.values
  }

  def getCountry(countryCode: String): CountryTrait = {
    countryMap(countryCode)
  }
}
