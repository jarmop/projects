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
    var dataSoc = List[List[Double]](List[Double](earnedIncome, tax.getSocialSecurityPercentage))

    for (earnedIncome <- 1000 to 100000 by 1000) {
      val tax = new Tax(earnedIncome, municipality, age)
      dataInc :+= List[Double](earnedIncome, tax.getIncomeTaxPercentage)
      dataSol :+= List[Double](earnedIncome, tax.getSolidaritySurchargePercentage)
      dataChu :+= List[Double](earnedIncome, tax.getChurchTaxPercentage)
      dataSoc :+= List[Double](earnedIncome, tax.getSocialSecurityPercentage)
    }

    Json.arr(
      Json.obj(
        "key" -> "Sosiaaliturva",
        "values" -> Json.toJson(dataSoc)
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
    var dataSoc = List[List[Double]](List[Double](earnedIncome, tax.getSocialSecurity))

    for (earnedIncome <- 1000 to 100000 by 1000) {
      val tax = new Tax(earnedIncome, municipality, age)
      dataInc :+= List[Double](earnedIncome, tax.getIncomeTax)
      dataSol :+= List[Double](earnedIncome, tax.getSolidaritySurcharge)
      dataChu :+= List[Double](earnedIncome, tax.getChurchTax)
      dataSoc :+= List[Double](earnedIncome, tax.getSocialSecurity)
    }

    Json.arr(
      Json.obj(
        "key" -> "Sosiaaliturva",
        "values" -> Json.toJson(dataSoc)
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
