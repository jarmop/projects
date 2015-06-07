package services

import models.sv.TaxEuro
import play.api.libs.json.{JsArray, Json}
import models.{fi,sv,de}

object CompareService {
  def getPercentData: JsArray = {
    val age = 30

    var salary = 0
    val taxFI = new models.fi.Tax(salary, "Helsinki", age)
    val taxSV = new sv.TaxEuro(salary, "Stockholm", age)
    val taxDE = new de.Tax(salary, "Berlin", age)
    var dataFI = List[List[Double]](List[Double](salary, taxFI.getTotalTaxPercentage))
    var dataSV = List[List[Double]](List[Double](salary, taxSV.getTotalTaxPercentage))
    var dataDE = List[List[Double]](List[Double](salary, taxDE.getTotalTaxPercentage))

    for (salary <- 1000 to 100000 by 1000) {
      val taxFI = new fi.Tax(salary, "Helsinki", age)
      val taxSV = new sv.TaxEuro(salary, "Stockholm", age)
      val taxDE = new de.Tax(salary, "Berlin", age)
      dataFI :+= List[Double](salary, taxFI.getTotalTaxPercentage)
      dataSV :+= List[Double](salary, taxSV.getTotalTaxPercentage)
      dataDE :+= List[Double](salary, taxDE.getTotalTaxPercentage)

    }

    Json.arr(
      Json.obj(
        "key" -> "Suomi",
        "values" -> Json.toJson(dataFI)
      ),
      Json.obj(
        "key" -> "Ruotsi",
        "values" -> Json.toJson(dataSV)
      ),
      Json.obj(
        "key" -> "Saksa",
        "values" -> Json.toJson(dataDE)
      )
    )
  }

  def getNetIncomeData: JsArray = {
    val age = 30

    var salary = 0
    val taxFI = new models.fi.Tax(salary, "Helsinki", age)
    val taxSV = new TaxEuro(salary, "Stockholm", age)
    val taxDE = new de.Tax(salary, "Berlin", age)
    var dataFI = List[List[Double]](List[Double](salary, taxFI.getNetIncome))
    var dataSV = List[List[Double]](List[Double](salary, taxSV.getNetIncome))
    var dataDE = List[List[Double]](List[Double](salary, taxDE.getNetIncome))

    for (salary <- 1000 to 100000 by 1000) {
      val taxFI = new fi.Tax(salary, "Helsinki", age)
      val taxSV = new sv.TaxEuro(salary, "Stockholm", age)
      val taxDE = new de.Tax(salary, "Berlin", age)
      dataFI :+= List[Double](salary, taxFI.getNetIncome)
      dataSV :+= List[Double](salary, taxSV.getNetIncome)
      dataDE :+= List[Double](salary, taxDE.getNetIncome)
    }

    Json.arr(
      Json.obj(
        "key" -> "Suomi",
        "values" -> Json.toJson(dataFI)
      ),
      Json.obj(
        "key" -> "Ruotsi",
        "values" -> Json.toJson(dataSV)
      ),
      Json.obj(
        "key" -> "Saksa",
        "values" -> Json.toJson(dataDE)
      )
    )
  }
}
