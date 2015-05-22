package controllers

import controllers.Application._
import controllers.MongoTest._
import services.CompareService
import play.api.libs.json.Json
import play.api.mvc._

import play.api._
import play.api.mvc._
import play.api.libs.concurrent.Execution.Implicits.defaultContext
import play.api.libs.functional.syntax._
import play.api.libs.json._
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

  def percent2 = Action.async {

    val json = CompareService.getPercentData


        collection.insert(Json.obj("_id" -> "jarmoid", "data" -> json)).map(lastError =>
          Ok("Mongo LastError: %s".format(lastError)))

    //Ok(json)
  }

  def percent = Action.async {
    // let's do our query
    val cursor: Cursor[JsObject] = collection.
      // find all people with name `name`
      find(Json.obj("_id" -> "jarmoid"))
        // sort them by creation date
        //.sort(Json.obj("created" -> -1))
        // perform the query and get a cursor of JsObject
        .cursor[JsObject]

    cursor.collect[List]().map { persons =>
      //Ok(Json.arr(persons))
      Ok(persons.productElement(0).asInstanceOf[play.api.libs.json.JsObject] \ "data")
    }

  }

  /*
   * Get a JSONCollection (a Collection implementation that is designed to work
   * with JsObject, Reads and Writes.)
   * Note that the `collection` is not a `val`, but a `def`. We do _not_ store
   * the collection reference to avoid potential problems in development with
   * Play hot-reloading.
   */
  //def sumCollection: JSONCollection = db.collection[JSONCollection]("persons")

  def sum2 = Action.async {
    val json = CompareService.getSumData

    collection.insert(Json.obj("_id" -> "compareSum", "data" -> json)).map(lastError =>
      Ok("Mongo LastError: %s".format(lastError)))

    //Ok(json)
  }

  def sum = Action.async {
    // let's do our query
    val cursor: Cursor[JsObject] = collection.
      // find all people with name `name`
      find(Json.obj("_id" -> "compareSum"))
      // sort them by creation date
      //.sort(Json.obj("created" -> -1))
      // perform the query and get a cursor of JsObject
      .cursor[JsObject]

    cursor.collect[List]().map { persons =>
      //Ok(Json.arr(persons))
      Ok(persons.productElement(0).asInstanceOf[play.api.libs.json.JsObject] \ "data")
    }

  }
}
