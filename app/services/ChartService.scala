package services

import models._
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

  def fillDataMap(dataMap: Map[String, ListBuffer[List[Double]]], getValue: (TaxTrait) => Double, range: Range, country: CountryTrait, key: String) = {
    for (earnedIncome <- range.start to range.end by range.step) {
      dataMap(key).append(List[Double](
        earnedIncome,
        getValue(country.getTax(earnedIncome))
      ))
    }
    dataMap
  }

  def fillDataMapAll(dataMap: Map[String, ListBuffer[List[Double]]], getValue: (TaxTrait) => Double, range: Range) = {
    for (countryCode <- CountryFactory.getCountryCodes) {
      fillDataMap(dataMap, getValue, range, CountryFactory.getCountry(countryCode), countryCode)
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

  def getDataAll(getValue: (TaxTrait) => Double): JsValue = {
    val dataMap = this.getDataMap
    this.fillDataMapAll(dataMap, getValue, 0 to 100000 by 1000)
    Json.toJson(this.dataMapToList(dataMap))
  }
  
  def getPercentage = (tax: TaxTrait) => {tax.getTotalTaxPercentage}
  def getSum = (tax: TaxTrait) => {tax.getTotalTax}
  def getNetIncome = (tax: TaxTrait) => {tax.getNetIncome}

  def getPercentDataAll: JsValue = {
    this.getDataAll(this.getPercentage)
  }

  def getSumDataAll: JsValue = {
    this.getDataAll(this.getSum)
  }

  def getNetIncomeDataAll: JsValue = {
    this.getDataAll(this.getNetIncome)
  }

  def fillDataList(range: Range, country: CountryTrait, getValue: (SubTaxValueSet) => Double) = {
    val dataList = country.getTax.getDataList
    for (earnedIncome <- range.start to range.end by range.step) {
      for (data <- dataList) {
        val tax = country.getTax(earnedIncome)
        data.values.append(
          List(
            earnedIncome,
            getValue(tax.getSubTaxValueSetByName(data.key))
          )
        )
      }
    }
    dataList
  }

  def getPercentage(subTaxValueSet: SubTaxValueSet) = {
    subTaxValueSet.percentage
  }

  def getSum(subTaxValueSet: SubTaxValueSet) = {
    subTaxValueSet.sum
  }

  def getPercentData(country: CountryTrait): JsValue = {
    Json.toJson(this.fillDataList(0 to 100000 by 1000, country, this.getPercentage))
  }
}
