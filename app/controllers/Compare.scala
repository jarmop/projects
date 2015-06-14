package controllers

import play.api.libs.json.Json
import play.api.mvc._
import play.api.libs.concurrent.Execution.Implicits.defaultContext
import play.api.libs.json._
import play.twirl.api.Html
import services.{CompareServiceFI, CompareService, CompareServiceSV, CompareServiceDE}
import play.modules.reactivemongo.MongoController
import play.modules.reactivemongo.json.collection.JSONCollection

case class Chart(title: String, graph: Html)
case class Tab(heading: String, select: String, charts: List[Chart], active: String="false")

object Compare extends Controller with MongoController {

  def index = Action {
    val assets = List[String](
      "javascripts/compare/CompareController.js",
      "javascripts/compare/CompareService.js"
    )

    val tabs = List[Tab](
      Tab("Veroprosentti", "loadAllPercent()", List[Chart](
        Chart("Suomi", this.getAreaChartPercent("fi.percent.data")),
        Chart("Ruotsi", this.getAreaChartPercent("sv.percent.data")),
        Chart("Saksa", this.getAreaChartPercent("de.percent.data"))
      ), active="true"),
      Tab("Verosumma", "loadAllSum()", List[Chart](
        Chart("Suomi", this.getAreaChartSum("fi.sum.data")),
        Chart("Ruotsi", this.getAreaChartSum("sv.sum.data")),
        Chart("Saksa", this.getAreaChartSum("de.sum.data"))
      )),
      Tab("Nettotulot", "loadAllNetIncome()", List[Chart](
        Chart("Suomi", this.getAreaChartSum("fi.netIncome.data")),
        Chart("Ruotsi", this.getAreaChartSum("sv.netIncome.data")),
        Chart("Saksa", this.getAreaChartSum("de.netIncome.data"))
      ))
    )

    Ok(views.html.compare("Vertaa", assets, tabs))
  }

  def getAreaChartPercent(data:String): Html = {
    views.html.areaChart(data, yAxisTickFormat="formatPercent()")
  }

  def getAreaChartSum(data:String): Html = {
    views.html.areaChart(data, yAxisTickFormat="formatSum()")
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
    val id = "fiComparePercent"
    if (update) {
      val json = CompareServiceFI.getPercentData
      this.update(id, json)
    } else {
      this.load(id)
    }
  }

  def fiSum(update: Boolean) = Action.async {
    val id = "fiCompareSum"
    if (update) {
      val json = CompareServiceFI.getSumData
      this.update(id, json)
    } else {
      this.load(id)
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

  def dePercent(update: Boolean) = Action.async {
    val id = "deComparePercent"
    if (update) {
      val json = CompareServiceDE.getPercentData
      this.update(id, json)
    } else {
      this.load(id)
    }
  }

  def deNetIncome(update: Boolean) = Action.async {
    val id = "deCompareNetIncome"
    if (update) {
      val json = CompareServiceDE.getNetIncomeData
      this.update(id, json)
    } else {
      this.load(id)
    }
  }

  def deSum(update: Boolean) = Action.async {
    val id = "deCompareSum"
    if (update) {
      val json = CompareServiceDE.getSumData
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
      "svCompareNetIncome" -> CompareServiceSV.getNetIncomeData,
      "svCompareSum" -> CompareServiceSV.getSumData,
      "deComparePercent" -> CompareServiceDE.getPercentData,
      "deCompareNetIncome" -> CompareServiceDE.getNetIncomeData,
      "deCompareSum" -> CompareServiceDE.getSumData
    )
    for ((key, data) <- keys) {
      collection.update(Json.obj("_id" -> key), Json.obj("data" -> data))
    }
    Ok("Updated all")
  }
}
