package services

import models.de.Tax
import play.api.libs.json.{Json, JsArray}

object CompareServiceDE {
  def getPercentData: JsArray = {
    val municipality = "Berlin"
    val age = 30

    var earnedIncome = 0
    val tax = new Tax(earnedIncome, municipality, age)
    var dataInc = List[List[Double]](List[Double](earnedIncome, tax.getIncomeTaxPercentage))
    var dataSol = List[List[Double]](List[Double](earnedIncome, tax.getSolidaritySurchargePercentage))
    var dataChu = List[List[Double]](List[Double](earnedIncome, tax.getChurchTaxPercentage))
    var dataPen = List[List[Double]](List[Double](earnedIncome, tax.getPensionIncurancePercentage))
    var dataUne = List[List[Double]](List[Double](earnedIncome, tax.getUnemploymentInsurancePercentage))
    var dataHea = List[List[Double]](List[Double](earnedIncome, tax.getHealthInsurancePercentage))
    var dataNur = List[List[Double]](List[Double](earnedIncome, tax.getNursingInsurancePercentage))


    for (earnedIncome <- 1000 to 100000 by 1000) {
      val tax = new Tax(earnedIncome, municipality, age)
      dataInc :+= List[Double](earnedIncome, tax.getIncomeTaxPercentage)
      dataSol :+= List[Double](earnedIncome, tax.getSolidaritySurchargePercentage)
      dataChu :+= List[Double](earnedIncome, tax.getChurchTaxPercentage)
      dataPen :+= List[Double](earnedIncome, tax.getPensionIncurancePercentage)
      dataUne :+= List[Double](earnedIncome, tax.getUnemploymentInsurancePercentage)
      dataHea :+= List[Double](earnedIncome, tax.getHealthInsurancePercentage)
      dataNur :+= List[Double](earnedIncome, tax.getNursingInsurancePercentage)
    }

    Json.arr(
      Json.obj(
        "key" -> "Terveysvakuutus",
        "values" -> Json.toJson(dataHea)
      ),
      Json.obj(
        "key" -> "Hoitovakuutus",
        "values" -> Json.toJson(dataNur)
      ),
      Json.obj(
        "key" -> "Eläkevakuutus",
        "values" -> Json.toJson(dataPen)
      ),
      Json.obj(
        "key" -> "Työttömyysvakuutus",
        "values" -> Json.toJson(dataUne)
      ),
      Json.obj(
        "key" -> "Solidaarisuusvero",
        "values" -> Json.toJson(dataSol)
      ),
      Json.obj(
        "key" -> "Kirkollisvero",
        "values" -> Json.toJson(dataChu)
      ),
      Json.obj(
        "key" -> "Tulovero",
        "values" -> Json.toJson(dataInc)
      )
    )
  }

  def getSumData: JsArray = {
    val municipality = "Berlin"
    val age = 30

    var earnedIncome = 0
    val tax = new Tax(earnedIncome, municipality, age)
    var dataInc = List[List[Double]](List[Double](earnedIncome, tax.getIncomeTax))
    var dataSol = List[List[Double]](List[Double](earnedIncome, tax.getSolidaritySurcharge))
    var dataChu = List[List[Double]](List[Double](earnedIncome, tax.getChurchTax))
    var dataPen = List[List[Double]](List[Double](earnedIncome, tax.getPensionIncurance))
    var dataUne = List[List[Double]](List[Double](earnedIncome, tax.getUnemploymentInsurance))
    var dataHea = List[List[Double]](List[Double](earnedIncome, tax.getHealthInsurance))
    var dataNur = List[List[Double]](List[Double](earnedIncome, tax.getNursingInsurance))


    for (earnedIncome <- 1000 to 100000 by 1000) {
      val tax = new Tax(earnedIncome, municipality, age)
      dataInc :+= List[Double](earnedIncome, tax.getIncomeTax)
      dataSol :+= List[Double](earnedIncome, tax.getSolidaritySurcharge)
      dataChu :+= List[Double](earnedIncome, tax.getChurchTax)
      dataPen :+= List[Double](earnedIncome, tax.getPensionIncurance)
      dataUne :+= List[Double](earnedIncome, tax.getUnemploymentInsurance)
      dataHea :+= List[Double](earnedIncome, tax.getHealthInsurance)
      dataNur :+= List[Double](earnedIncome, tax.getNursingInsurance)
    }

    Json.arr(
      Json.obj(
        "key" -> "Terveysvakuutus",
        "values" -> Json.toJson(dataHea)
      ),
      Json.obj(
        "key" -> "Hoitovakuutus",
        "values" -> Json.toJson(dataNur)
      ),
      Json.obj(
        "key" -> "Eläkevakuutus",
        "values" -> Json.toJson(dataPen)
      ),
      Json.obj(
        "key" -> "Työttömyysvakuutus",
        "values" -> Json.toJson(dataUne)
      ),
      Json.obj(
        "key" -> "Solidaarisuusvero",
        "values" -> Json.toJson(dataSol)
      ),
      Json.obj(
        "key" -> "Kirkollisvero",
        "values" -> Json.toJson(dataChu)
      ),
      Json.obj(
        "key" -> "Tulovero",
        "values" -> Json.toJson(dataInc)
      )
    )
  }

  def getNetIncomeData: JsArray = {
    val municipality = "Stockholm"
    val age = 30

    var earnedIncome = 0
    val tax = new Tax(earnedIncome, municipality, age)
    var dataNet = List[List[Double]](List[Double](earnedIncome, tax.getNetIncome))
    var dataTax = List[List[Double]](List[Double](earnedIncome, tax.getTotalTax))


    for (earnedIncome <- 1000 to 100000 by 1000) {
      val tax = new Tax(earnedIncome, municipality, age)
      dataNet :+= List[Double](earnedIncome, tax.getNetIncome)
      dataTax :+= List[Double](earnedIncome, tax.getTotalTax)

    }

    Json.arr(
      Json.obj(
        "key" -> "Nettotulot",
        "values" -> Json.toJson(dataNet)
      ),
      Json.obj(
        "key" -> "Vero",
        "values" -> Json.toJson(dataTax)
      )
    )
  }
}
