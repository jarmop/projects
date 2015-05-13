package controllers

import models.Tax
import play.api.libs.json.Json
import play.api.mvc._

object Application extends Controller {

  def index = Action {
    Ok(views.html.index("Verotutka"))
  }

  def tax = Action {
    val tax = new Tax(salary = 30000, municipality = "Helsinkity", age = 30)
    Ok(Json.toJson(tax))
  }

}