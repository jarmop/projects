package controllers

import models.Tax
import play.api.libs.json.Json
import play.api.mvc._

object Application extends Controller {

  def index = Action {
    Ok(views.html.index("Verotutka"))
  }

  def tax = Action { request =>
    val salary = request.getQueryString("salary").get.toDouble.toFloat
    val municipality = request.getQueryString("municipality").get
    val age = request.getQueryString("age").get.toInt

    val tax = new Tax(salary, municipality, age)
    Ok(Json.toJson(tax))
  }

}