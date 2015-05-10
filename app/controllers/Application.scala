package controllers

import models.{Tax}
import play.api._
import play.api.data._
import play.api.data.Form
import play.api.data.Forms._
import play.api.mvc._


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

  def calculate = Action { implicit request =>
    val (salary, municipality, age) = taxForm.bindFromRequest.get
    Ok(salary + municipality + age)
    //Redirect(routes.Application.index)
  }

}