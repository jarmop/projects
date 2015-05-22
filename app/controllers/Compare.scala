package controllers

import controllers.Application._
import models.Tax
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

  def percent = Action.async {
    val municipality = "Helsinki"
    val age = 30

    val tax = new Tax(1000000, municipality, age)
    var salary = 1000000
    //var data = List[List[Double]](List[Double](salary / 100, tax.getTotalTax / salary * 100))
    var dataGov = List[List[Double]](List[Double](salary / 100, tax.getGovernmentTaxPercent * 100))
    var dataMun = List[List[Double]](List[Double](salary / 100, tax.getMunicipalityTaxPercent * 100))
    var dataMed = List[List[Double]](List[Double](salary / 100, tax.getMedicalCareInsurancePaymentPercent * 100))
    var dataPer = List[List[Double]](List[Double](salary / 100, tax.getPerDiemPaymentPercent * 100))
    var dataYle = List[List[Double]](List[Double](salary / 100, tax.getYleTaxPercent * 100))
    //var net = List[List[Double]](List[Double](salary / 100, (salary - tax.getTotalTax) / salary * 100))

    for (salary <- 1100000 to 10000000 by 100000) {
      val tax = new Tax(salary, municipality, age)
      //data :+= List[Double](salary / 100, tax.getTotalTax / salary * 100)
      dataGov :+= List[Double](salary / 100, tax.getGovernmentTaxPercent * 100)
      dataMun :+= List[Double](salary / 100, tax.getMunicipalityTaxPercent * 100)
      dataMed :+= List[Double](salary / 100, tax.getMedicalCareInsurancePaymentPercent * 100)
      dataPer :+= List[Double](salary / 100, tax.getPerDiemPaymentPercent * 100)
      dataYle :+= List[Double](salary / 100, tax.getYleTaxPercent * 100)
      //net :+= List[Double](salary / 100, (salary - tax.getTotalTax) / salary * 100)
    }

    val json = Json.arr(
      Json.obj(
        "key" -> "Päivärahamaksu",
        "values" -> Json.toJson(dataPer)
      ),
      Json.obj(
        "key" -> "YLE-vero",
        "values" -> Json.toJson(dataYle)
      ),
      Json.obj(
        "key" -> "Sairaanhoitomaksu",
        "values" -> Json.toJson(dataMed)
      ),
      Json.obj(
        "key" -> "Kunnallisvero",
        "values" -> Json.toJson(dataMun)
      ),
      Json.obj(
        "key" -> "Valtion vero",
        "values" -> Json.toJson(dataGov)
      )
    )

        collection.insert(Json.obj("_id" -> "jarmoid", "data" -> json)).map(lastError =>
          Ok("Mongo LastError: %s".format(lastError)))

    /*Ok(Json.arr(
      Json.obj(
        "key" -> "Päivärahamaksu",
        "values" -> Json.toJson(dataPer)
      ),
      Json.obj(
        "key" -> "YLE-vero",
        "values" -> Json.toJson(dataYle)
      ),
      Json.obj(
        "key" -> "Sairaanhoitomaksu",
        "values" -> Json.toJson(dataMed)
      ),
      Json.obj(
        "key" -> "Kunnallisvero",
        "values" -> Json.toJson(dataMun)
      ),
      Json.obj(
        "key" -> "Valtion vero",
        "values" -> Json.toJson(dataGov)
      )
    ))*/
  }

  def sum = Action {
    val municipality = "Helsinki"
    val age = 30

    val tax = new Tax(1000000, municipality, age)
    var salary = 1000000
    //var data = List[List[Double]](List[Double](salary / 100, tax.getTotalTax / salary * 100))
    var dataGov = List[List[Double]](List[Double](salary / 100, tax.getGovernmentTax / 100))
    var dataMun = List[List[Double]](List[Double](salary / 100, tax.getMunicipalityTax / 100))
    var dataMed = List[List[Double]](List[Double](salary / 100, tax.getMedicalCareInsurancePayment / 100))
    var dataPer = List[List[Double]](List[Double](salary / 100, tax.getPerDiemPayment / 100))
    var dataYle = List[List[Double]](List[Double](salary / 100, tax.getYleTax / 100))
    //var net = List[List[Double]](List[Double](salary / 100, (salary - tax.getTotalTax) / salary * 100))

    for (salary <- 1100000 to 10000000 by 100000) {
      val tax = new Tax(salary, municipality, age)
      //data :+= List[Double](salary / 100, tax.getTotalTax / salary * 100)
      dataGov :+= List[Double](salary / 100, tax.getGovernmentTax / 100)
      dataMun :+= List[Double](salary / 100, tax.getMunicipalityTax / 100)
      dataMed :+= List[Double](salary / 100, tax.getMedicalCareInsurancePayment / 100)
      dataPer :+= List[Double](salary / 100, tax.getPerDiemPayment / 100)
      dataYle :+= List[Double](salary / 100, tax.getYleTax / 100)
      //net :+= List[Double](salary / 100, (salary - tax.getTotalTax) / salary * 100)
    }

    Ok(Json.arr(
      Json.obj(
        "key" -> "Päivärahamaksu",
        "values" -> Json.toJson(dataPer)
      ),
      Json.obj(
        "key" -> "YLE-vero",
        "values" -> Json.toJson(dataYle)
      ),
      Json.obj(
        "key" -> "Sairaanhoitomaksu",
        "values" -> Json.toJson(dataMed)
      ),
      Json.obj(
        "key" -> "Kunnallisvero",
        "values" -> Json.toJson(dataMun)
      ),
      Json.obj(
        "key" -> "Valtion vero",
        "values" -> Json.toJson(dataGov)
      )
    ))
  }
}
