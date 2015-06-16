package services

import models.{TaxTrait, CountryFactory}
import play.api.libs.json.{Writes, JsValue, Json}
import scala.collection.mutable.{ListBuffer, Map}

case class Data(key: String, values: ListBuffer[List[Double]])
object Data {
  implicit val dataWrites = new Writes[Data] {
    def writes(data: Data) = Json.obj(
      "key" -> data.key,
      "values" -> Json.toJson(data.values)
    )
  }
}

object ChartService {
  def getDataMap: Map[String, ListBuffer[List[Double]]] = {
    var dataMap = Map[String, ListBuffer[List[Double]]]()
    for (countryCode <- CountryFactory.getCountryCodes) {
      dataMap.put(countryCode, new ListBuffer[List[Double]])
    }
    dataMap
  }

  def fillDataMap(dataMap: Map[String, ListBuffer[List[Double]]], getValue: (TaxTrait) => Double, range: Range) = {
    for (earnedIncome <- 0 to 100000 by 1000) {
      for (countryCode <- CountryFactory.getCountryCodes) {
        dataMap(countryCode).append(List[Double](
          earnedIncome,
          getValue(CountryFactory.getCountry(countryCode).getTax(earnedIncome))
        ))
      }
    }
    dataMap
  }

  def dataMapToList(dataMap: Map[String, ListBuffer[List[Double]]]): ListBuffer[Data] = {
    val dataList = new ListBuffer[Data]
    for ((countryCode, data) <- dataMap) {
      dataList.append(Data(CountryFactory.getCountry(countryCode).getName, data))
    }
    dataList
  }

  def getData(getValue: (TaxTrait) => Double): JsValue = {
    var dataMap = this.getDataMap
    dataMap = this.fillDataMap(dataMap, getValue, 0 to 100000 by 1000)
    Json.toJson(this.dataMapToList(dataMap))
  }

  def getPercentData: JsValue = {
    this.getData((tax: TaxTrait) => {tax.getTotalTaxPercentage})
  }

  def getSumData: JsValue = {
    this.getData((tax: TaxTrait) => {tax.getTotalTax})
  }

  def getNetIncomeData: JsValue = {
    this.getData((tax: TaxTrait) => {tax.getNetIncome})
  }
}
