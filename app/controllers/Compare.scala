package controllers

import controllers.Application._
import controllers.MongoTest._
import play.api.libs.json.Json
import play.api.mvc._

import play.api._
import play.api.mvc._
import play.api.libs.concurrent.Execution.Implicits.defaultContext
import play.api.libs.functional.syntax._
import play.api.libs.json._
import services.fi.CompareService
import scala.concurrent.Future

// Reactive Mongo imports
import reactivemongo.api._

// Reactive Mongo plugin, including the JSON-specialized collection
import play.modules.reactivemongo.MongoController
import play.modules.reactivemongo.json.collection.JSONCollection

object Compare extends Controller with MongoController {

  def index = Action {
    val assets = List[String](
      "javascripts/compare/CompareController.js",
      "javascripts/compare/CompareService.js"
    )

    Ok(views.html.compare("Vertaa", assets))
  }

  /*
   * Get a JSONCollection (a Collection implementation that is designed to work
   * with JsObject, Reads and Writes.)
   * Note that the `collection` is not a `val`, but a `def`. We do _not_ store
   * the collection reference to avoid potential problems in development with
   * Play hot-reloading.
   */
  def collection: JSONCollection = db.collection[JSONCollection]("persons")

  def percent(update: Boolean) = Action.async {
    if (update) {
      val json = CompareService.getPercentData
      collection.update(Json.obj("_id" -> "comparePercent"), Json.obj("data" -> json)).map(lastError =>
        Ok("updated percent json")
      )
    } else {
      collection
        .find(Json.obj("_id" -> "comparePercent"))
        .one[JsObject]
        .map { json =>
        if (json.nonEmpty) {
          Ok(json.get \ "data")
        } else {
          Ok(Json.arr())
        }

      }
    }



    /**/

  }

  def sum(update: Boolean) = Action.async {
    if (update) {
      val json = CompareService.getSumData
      collection.update(Json.obj("_id" -> "compareSum"), Json.obj("data" -> json)).map(lastError =>
        Ok("updated sum json")
      )
    } else {
      collection
        .find(Json.obj("_id" -> "compareSum"))
        .one[JsObject]
        .map { json =>
        // if not found calculate
        Ok(json.get \ "data")
      }
    }

  }
}
