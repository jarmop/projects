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
import services.{CompareServiceFI, CompareService, CompareServiceSV}
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
    val id = "comparePercent"
    if (update) {
      val data = CompareService.getPercentData
      this.update(id, data)
    } else {
      this.load(id)
    }
  }

  def netIncome(update: Boolean) = Action.async {
    val id = "compareNetIncome"
    if (update) {
      val data = CompareService.getNetIncomeData
      this.update(id, data)
    } else {
      this.load(id)
    }
  }

  def fiPercent(update: Boolean) = Action.async {
    if (update) {
      val json = CompareServiceFI.getPercentData
      collection.update(Json.obj("_id" -> "fiComparePercent"), Json.obj("data" -> json)).map(lastError =>
        Ok("updated percent json")
      )
    } else {
      collection
        .find(Json.obj("_id" -> "fiComparePercent"))
        .one[JsObject]
        .map { json =>
        if (json.nonEmpty) {
          Ok(json.get \ "data")
        } else {
          Ok(Json.arr())
        }

      }
    }
  }

  def fiSum(update: Boolean) = Action.async {
    if (update) {
      val json = CompareServiceFI.getSumData
      collection.update(Json.obj("_id" -> "fiCompareSum"), Json.obj("data" -> json)).map(lastError =>
        Ok("updated sum json")
      )
    } else {
      collection
        .find(Json.obj("_id" -> "fiCompareSum"))
        .one[JsObject]
        .map { json =>
        Ok(json.get \ "data")
      }
    }
  }

  def fiNetIncome(update: Boolean) = Action.async {
    val id = "fiCompareNetIncome"
    if (update) {
      val json = CompareServiceFI.getNetIncomeData
      this.update(id, json)
    } else {
      this.load(id)
    }
  }

  def svPercent(update: Boolean) = Action.async {
    val id = "svComparePercent"
    if (update) {
      val json = CompareServiceSV.getPercentData
      this.update(id, json)
    } else {
      this.load(id)
    }
  }

  def svNetIncome(update: Boolean) = Action.async {
    val id = "svCompareNetIncome"
    if (update) {
      val json = CompareServiceSV.getNetIncomeData
      this.update(id, json)
    } else {
      this.load(id)
    }
  }

  def svSum(update: Boolean) = Action.async {
    val id = "svCompareSum"
    if (update) {
      val json = CompareServiceSV.getSumData
      this.update(id, json)
    } else {
      this.load(id)
    }
  }

  def update(id: String, data: JsArray) = {
    collection.update(Json.obj("_id" -> id), Json.obj("data" -> data)).map(lastError =>
      Ok("updated " + id)
    )
  }

  def load(id: String) = {
    collection
      .find(Json.obj("_id" -> id))
      .one[JsObject]
      .map { json =>
      Ok(json.get \ "data")
    }
  }

  def updateAll = Action {
    val keys = Map[String, JsArray](
      "comparePercent" -> CompareService.getPercentData,
      "compareNetIncome" -> CompareService.getNetIncomeData,
      "fiComparePercent" -> CompareServiceFI.getPercentData,
      "fiCompareNetIncome" -> CompareServiceFI.getNetIncomeData,
      "fiCompareSum" -> CompareServiceFI.getSumData,
      "svComparePercent" -> CompareServiceSV.getPercentData,
      "svCompareNetIncome" -> CompareServiceSV.getNetIncomeData
    )
    for ((key, data) <- keys) {
      collection.update(Json.obj("_id" -> key), Json.obj("data" -> data))
    }
    Ok("Updated all")
  }
}
