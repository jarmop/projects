package controllers

import models.{Tax,Book,MunicipalityTax}
import play.api._
import play.api.data._
import play.api.data.Form
import play.api.data.Forms._
import play.api.libs.json.{JsArray, Json}
import play.api.mvc._

import scala.concurrent.Future

import models.Book._


object Application extends Controller {

  def index = Action {
    Ok(views.html.index("Verotutka"))
  }

  val taxForm = Form(
    tuple(
      "salary" -> text,
      "municipality" -> text,
      "age" -> number
    )
  )

  def taxi = Action { implicit request =>
    Ok("rthrt")
    //val (salary, municipality, age) = taxForm.bindFromRequest.get
    //Ok(salary + municipality + age)
    //Redirect(routes.Application.index)
  }

  def tax = Action {
    val tax = new Tax(salary = 30000, municipality = "Helsinkity", age = 30)
    //Ok(tax.toJson)
    Ok(Json.toJson(tax))
    //Ok(Json.toJson(taxit))
    //Ok("erfer");
  }

  def listBooks = Action {
    Ok(Json.toJson(books))
  }

}