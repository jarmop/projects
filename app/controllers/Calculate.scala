package controllers

import controllers.Application._
import models.CountryFactory
import play.api.mvc.Action

object Calculate {
  def index = Action {
    val assets = List[String](
      "javascripts/calculate/CalculateController.js",
      "javascripts/calculate/CalculateService.js"
    )

    Ok(views.html.calculate("Verolaskuri 2015", assets))
  }

  def tax(countryCode: String, earnedIncome: Double) = Action { request =>
    if (CountryFactory.isValidCountryCode(countryCode)) {
      Ok(CountryFactory.getCountry(countryCode).getTax(earnedIncome).getJson)
    } else {
      Ok("Country not found")
    }
  }
}
