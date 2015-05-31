package services.country

import play.api.libs.json.{JsArray, Json}
import models.{fi,sv}
import services.CurrencyConverter

object CountryComparison {
  def getCountryData: JsArray = {
    val age = 30

    var salary = 1000000
    val taxFI = new models.fi.Tax(salary, "Helsinki", age)
    val taxSV = new sv.Tax(CurrencyConverter.EuroToSVKrona(salary / 100), "Stockholm", age)
    var dataFI = List[List[Double]](List[Double](salary, taxFI.getTotalTaxPercentage))
    var dataSV = List[List[Double]](List[Double](salary, taxSV.getTotalTaxPercentage))

    for (salary <- 2000000 to 10000000 by 1000000) {
      val taxFI = new fi.Tax(salary, "Helsinki", age)
      val taxSV = new sv.Tax(CurrencyConverter.EuroToSVKrona(salary / 100), "Stockholm", age)
      dataFI :+= List[Double](salary, taxFI.getTotalTaxPercentage)
      dataSV :+= List[Double](salary, taxSV.getTotalTaxPercentage)
    }

    Json.arr(
      Json.obj(
        "key" -> "Suomi",
        "values" -> Json.toJson(dataFI)
      ),
      Json.obj(
        "key" -> "Ruotsi",
        "values" -> Json.toJson(dataSV)
      )
    )
  }
}
