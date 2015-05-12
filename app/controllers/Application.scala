package controllers

import models.{Tax,Book}
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
    Ok("gre");

  }

  def listBooks = Action {
    Ok(Json.toJson(books))
  }

}