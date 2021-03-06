package controllers

import javax.inject.{Singleton, Inject}
import models.de.Germany
import models.fi.Finland
import models.sv.Sweden
import play.api.mvc._
import play.api.libs.concurrent.Execution.Implicits.defaultContext
import play.api.libs.json._
import play.twirl.api.Html
import services.ChartService
import play.modules.reactivemongo.{ReactiveMongoApi, ReactiveMongoComponents, MongoController}
import play.modules.reactivemongo.json.collection.JSONCollection
import models.CountryFactory
import play.modules.reactivemongo.json._

case class Chart(title: String, graph: Html)
case class Tab(heading: String, select: String, charts: List[Chart], active: String="false")

@Singleton
class Compare @Inject() (val reactiveMongoApi: ReactiveMongoApi)
  extends Controller with MongoController with ReactiveMongoComponents {

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

  def getAreaChartPercent(data: String): Html = {
    views.html.areaChart(data, yAxisTickFormat="formatPercent()")
  }

  def getAreaChartSum(data: String): Html = {
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

  def getId(dataType: String, country: String = ""): String = {
    var id = "compare." + dataType
    if (country.length > 0) { id += "." + country }
    id
  }

  def getPercent(country: String) = country match {
    case "fi" => ChartService.getPercentData(Finland)
    case "sv" => ChartService.getPercentData(Sweden)
    case "de" => ChartService.getPercentData(Germany)
    case "" => ChartService.getPercentDataAll
  }

  def getSum(country: String) = country match {
    case "fi" => ChartService.getSumData(Finland)
    case "sv" => ChartService.getSumData(Sweden)
    case "de" => ChartService.getSumData(Germany)
  }

  def getNetIncome(country: String) = country match {
    case "fi" => ChartService.getNetIncomeData(Finland)
    case "sv" => ChartService.getNetIncomeData(Sweden)
    case "de" => ChartService.getNetIncomeData(Germany)
    case "" => ChartService.getNetIncomeDataAll
  }

  def getData(dataType: String, country: String = "") = dataType match {
    case "percent" => this.getPercent(country)
    case "sum" => this.getSum(country)
    case "net-income" => this.getNetIncome(country)
  }

  def updateData(dataType: String, country: String) = Action.async {
    val id = this.getId(dataType, country)
    val data = this.getData(dataType, country)
    collection.update(Json.obj("_id" -> id), Json.obj("data" -> data)).map(lastError =>
      Ok("updated " + id)
    )
  }

  def loadData(dataType: String, country: String = "") = Action.async {
    val id = this.getId(dataType, country)
    collection
      .find(Json.obj("_id" -> id))
      .one[JsObject]
      .map { json =>
      Ok((json.get \ "data").get)
    }
  }

  def updateAll = Action {
    val types = List[String]("percent", "sum", "net-income")
    for (dataType <- types) {
      for (country <- CountryFactory.getCountryCodes) {
        collection.update(
          Json.obj("_id" -> this.getId(dataType, country)),
          Json.obj("data" -> this.getData(dataType, country))
        )
      }
    }
    collection.update(Json.obj("_id" -> this.getId("percent")), Json.obj("data" -> this.getData("percent")))
    collection.update(Json.obj("_id" -> this.getId("net-income")), Json.obj("data" -> this.getData("net-income")))

    Ok("Updated all")
  }
}
