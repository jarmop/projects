package controllers

import javax.inject.Singleton
import models.CountryFactory
import play.api.mvc.{Controller, Action}

@Singleton
class Calculate extends Controller {
  def index(countryCode: String, earnedIncome: Double) = Action {
    val assets = List[String](
      "javascripts/calculate/CalculateController.js",
      "javascripts/calculate/CalculateService.js"
    )

    Ok(views.html.calculate("Verolaskuri 2015", assets, countryCode, earnedIncome))
  }

  def data(countryCode: String, earnedIncome: Double) = Action { request =>
    if (CountryFactory.isValidCountryCode(countryCode)) {
      Ok(CountryFactory.getCountry(countryCode).getTax(earnedIncome).getJson)
    } else {
      Ok("Country not found")
    }
  }
}
