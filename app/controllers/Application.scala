package controllers

import models.de.Tax
import models.sv.TaxEuro
import models._
import play.api.mvc._

object Application extends Controller {

  def index = Action {
    val assets = List[String](
      "javascripts/d3pie.js",
      "javascripts/TaxController.js",
      "javascripts/TaxService.js",
      "javascripts/PieService.js"
    )

    Ok(views.html.index("Verolaskuri 2015", assets))
  }

  def tax(countryCode: String, earnedIncome: Double, municipality: Option[String], age: Option[Int]) = Action { request =>
    if (CountryFactory.isValidCountryCode(countryCode)) {
      Ok(CountryFactory.getCountry(countryCode).getTax(earnedIncome).getJson)
    } else {
      Ok("Country not found")
    }
  }
}