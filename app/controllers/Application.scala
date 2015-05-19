package controllers

import models.Tax
import play.api.libs.json.Json
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

  def tax = Action { request =>
    val salary = request.getQueryString("salary").get.toInt
    val municipality = request.getQueryString("municipality").get
    val age = request.getQueryString("age").get.toInt

    val tax = new Tax(salary, municipality, age)
    Ok(Json.toJson(tax))
  }

}