package controllers

import models.{fi,sv,de}
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

  def taxFI = Action { request =>
    val salary = request.getQueryString("salary").get.toInt
    val municipality = request.getQueryString("municipality").get
    val age = request.getQueryString("age").get.toInt

    val tax = new fi.Tax(salary, municipality, age)
    Ok(tax.getJson)
  }

  def taxSV = Action { request =>
    val salary = request.getQueryString("salary").get.toInt
    val municipality = request.getQueryString("municipality").get
    val age = request.getQueryString("age").get.toInt

    val tax = new sv.Tax(salary, municipality, age)
    Ok(tax.getJson)
  }

  def taxDE = Action { request =>
    val salary = request.getQueryString("salary").get.toInt
    val municipality = request.getQueryString("municipality").get
    val age = request.getQueryString("age").get.toInt

    val tax = new de.Tax(salary, municipality, age)
    Ok(tax.getJson)
  }

}