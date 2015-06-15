package services

import models.CountryFactory
import play.api.libs.json.{Writes, JsValue, Json}
import scala.collection.mutable.ListBuffer

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
  def getPercentData: JsValue = {
    var dataMap = scala.collection.mutable.Map[String, ListBuffer[List[Double]]]()
    for (countryCode <- CountryFactory.getCountryCodes) {
      dataMap.put(countryCode, new ListBuffer[List[Double]])
    }

    for (earnedIncome <- 0 to 100000 by 1000) {
      for (countryCode <- CountryFactory.getCountryCodes) {
        dataMap(countryCode).append(List[Double](
          earnedIncome,
          CountryFactory.getCountry(countryCode).getTax(earnedIncome).getTotalTaxPercentage
        ))
      }
    }

    val dataList = new ListBuffer[Data]
    for ((countryCode, data) <- dataMap) {
      dataList.append(Data(CountryFactory.getCountry(countryCode).getName, data))
    }

    Json.toJson(dataList)
  }
}
