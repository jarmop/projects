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

  def fillDataMap(dataMap: Map[String, ListBuffer[List[Double]]], getValue: (TaxTrait) => Double, range: Range, countryCode: String) = {
    for (earnedIncome <- range.start to range.end by range.step) {
      dataMap(countryCode).append(List[Double](
        earnedIncome,
        getValue(CountryFactory.getCountry(countryCode).getTax(earnedIncome))
      ))
    }
    dataMap
  }

  def fillDataMapAll(dataMap: Map[String, ListBuffer[List[Double]]], getValue: (TaxTrait) => Double, range: Range) = {
    for (countryCode <- CountryFactory.getCountryCodes) {
      fillDataMap(dataMap, getValue, range, countryCode)
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
    val dataMap = this.getDataMap
    this.fillDataMapAll(dataMap, getValue, 0 to 100000 by 1000)
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
