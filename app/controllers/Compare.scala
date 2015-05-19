package controllers

import play.api.libs.json.Json
import play.api.mvc._

object Compare extends Controller {

  def index = Action {
    val assets = List[String](
      "javascripts/compare/CompareController.js",
      "javascripts/compare/CompareService.js"
    )

    Ok(views.html.compare("Vertaa", assets))
  }
}
