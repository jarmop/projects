package services

import play.api.libs.json.{JsArray, Json}
import models.{fi,sv}

object compareService {
  def getPercentData: JsArray = {
    val age = 30

    var salary = 1000
    val taxFI = new models.fi.Tax(salary, "Helsinki", age)
    val taxSV = new sv.Tax(euroToSVKrona(salary), "Stockholm", age)
    var dataFI = List[List[Double]](List[Double](salary, taxFI.getTotalTaxPercentage))
    var dataSV = List[List[Double]](List[Double](salary, taxSV.getTotalTaxPercentage))

    for (salary <- 2000 to 100000 by 1000) {
      val taxFI = new fi.Tax(salary, "Helsinki", age)
      val taxSV = new sv.Tax(euroToSVKrona(salary), "Stockholm", age)
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

  def getNetIncomeData: JsArray = {
    val age = 30

    var salary = 1000
    val taxFI = new models.fi.Tax(salary, "Helsinki", age)
    val taxSV = new sv.Tax(euroToSVKrona(salary), "Stockholm", age)
    var dataFI = List[List[Double]](List[Double](salary, taxFI.getNetIncome))
    var dataSV = List[List[Double]](List[Double](salary, svKronaToEuro(taxSV.getNetIncome)))

    for (salary <- 2000 to 100000 by 1000) {
      val taxFI = new fi.Tax(salary, "Helsinki", age)
      val taxSV = new sv.Tax(euroToSVKrona(salary), "Stockholm", age)
      dataFI :+= List[Double](salary, taxFI.getNetIncome)
      dataSV :+= List[Double](salary, svKronaToEuro(taxSV.getNetIncome))
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
