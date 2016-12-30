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
  
  private def getPercentage = (tax: TaxTrait) => {tax.getTotalTaxPercentage}
  private def getSum = (tax: TaxTrait) => {tax.getTotalTax}
  private def getNetIncome = (tax: TaxTrait) => {tax.getNetIncome}

  def getPercentDataAll: JsValue = {
    this.getDataAll(this.getPercentage)
  }

  def getSumDataAll: JsValue = {
    this.getDataAll(this.getSum)
  }

  def getNetIncomeDataAll: JsValue = {
    this.getDataAll(this.getNetIncome)
  }

  private def fillDataList(range: Range, country: CountryTrait, getValue: (TaxValue) => Double) = {
    val dataList = new ListBuffer[Data]
    for (earnedIncome <- range.start to range.end by range.step) {
      val tax = country.getTax(earnedIncome)
      for (taxValue <- tax.getValues) {
        val valueSet = List[Double](earnedIncome, getValue(taxValue))
        dataList.find((data) => data.key == taxValue.name) match {
          case Some(data) => data.values.append(valueSet)
          case None =>
            val dataValues = new ListBuffer[List[Double]]
            dataValues.append(valueSet)
            dataList.append(Data(taxValue.name, dataValues))
        }
      }
    }
    dataList
  }

  private def getPercentage(taxValue: TaxValue) = {
    taxValue.percentage
  }

  private def getSum(taxValue: TaxValue) = {
    taxValue.sum
  }

  def getPercentData(country: CountryTrait): JsValue = {
    Json.toJson(this.fillDataList(0 to 100000 by 1000, country, this.getPercentage))
  }

  def getSumData(country: CountryTrait): JsValue = {
    Json.toJson(this.fillDataList(0 to 100000 by 1000, country, this.getSum))
  }


  def getNetIncomeData(country: CountryTrait): JsValue = {
    val taxList = new ListBuffer[List[Double]]
    val netIncomeList = new ListBuffer[List[Double]]
    for (earnedIncome <- 0 to 100000 by 1000) {
      val tax = country.getTax(earnedIncome)
      taxList.append(List(
        earnedIncome,
        tax.getTotalTax
      ))
      netIncomeList.append(List(
        earnedIncome,
        tax.getNetIncome
      ))
    }
    Json.toJson(List[Data](
      Data("Nettotulot", netIncomeList),
      Data("Vero", taxList)
    ))
  }
}
