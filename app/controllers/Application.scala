package controllers

import models.de.Tax
import models.sv.TaxEuro
import models.{TaxTrait, fi, sv, de}
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

  def tax(country: String, earnedIncome: Double, municipality: Option[String], age: Option[Int]) = Action { request =>
    val tax = this.getTax(country, earnedIncome, municipality, age.getOrElse(30))
    Ok(tax.getJson)
  }

  def getTax(country: String, earnedIncome: Double, municipality: Option[String], age: Int): models.TaxTrait = country match {
    case "fi" => new fi.Tax(earnedIncome, municipality.getOrElse("Helsinki"), age)
    case "sv" => new TaxEuro(earnedIncome, municipality.getOrElse("Stockholm"), age)
    case "de" => new de.Tax(earnedIncome, municipality.getOrElse("Berlin"), age)
  }
}