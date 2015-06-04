package services

import models.sv.TaxEuro
import play.api.libs.json.{Json, JsArray}

object CompareServiceSV {
  def getPercentData: JsArray = {
    val municipality = "Stockholm"
    val age = 30

    var salary = 1000
    val tax = new TaxEuro(salary, municipality, age)
    var dataSta = List[List[Double]](List[Double](salary, tax.getStateTaxPercentage))
    var dataMun = List[List[Double]](List[Double](salary, tax.getMunicipalityTaxPercentage))
    var dataCou = List[List[Double]](List[Double](salary, tax.getCountyTaxPercentage))
    var dataChu = List[List[Double]](List[Double](salary, tax.getChurchPaymentPercentage))
    var dataFun = List[List[Double]](List[Double](salary, tax.getFuneralPaymentPercentage))
    var dataPen = List[List[Double]](List[Double](salary, tax.getPensionContributionPercentage))
    var dataCre = List[List[Double]](List[Double](salary, tax.getTaxCreditPercentage))

    for (salary <- 2000 to 100000 by 1000) {
      val tax = new TaxEuro(salary, municipality, age)
      dataSta :+= List[Double](salary, tax.getStateTaxPercentage)
      dataMun :+= List[Double](salary, tax.getMunicipalityTaxPercentage)
      dataCou :+= List[Double](salary, tax.getCountyTaxPercentage)
      dataChu :+= List[Double](salary, tax.getChurchPaymentPercentage)
      dataFun :+= List[Double](salary, tax.getFuneralPaymentPercentage)
      dataPen :+= List[Double](salary, tax.getPensionContributionPercentage)
      dataCre :+= List[Double](salary, tax.getTaxCreditPercentage)
    }

    Json.arr(
      Json.obj(
        "key" -> "Eläkemaksu",
        "values" -> Json.toJson(dataPen)
      ),
      Json.obj(
        "key" -> "Kirkollisvero",
        "values" -> Json.toJson(dataChu)
      ),
      Json.obj(
        "key" -> "Hautajaismaksu",
        "values" -> Json.toJson(dataFun)
      ),
      Json.obj(
        "key" -> "Maakuntavero",
        "values" -> Json.toJson(dataCou)
      ),
      Json.obj(
        "key" -> "Kunnallisvero",
        "values" -> Json.toJson(dataMun)
      ),
      Json.obj(
        "key" -> "Valtion vero",
        "values" -> Json.toJson(dataSta)
      )/*,
      Json.obj(
        "key" -> "Vähennys",
        "values" -> Json.toJson(dataCre)
      )*/
    )
  }

  def getSumData: JsArray = {
    val municipality = "Stockholm"
    val age = 30

    var salary = 1000
    val tax = new TaxEuro(salary, municipality, age)
    var dataSta = List[List[Double]](List[Double](salary, tax.getStateTax))
    var dataMun = List[List[Double]](List[Double](salary, tax.getMunicipalityTax))
    var dataCou = List[List[Double]](List[Double](salary, tax.getCountyTax))
    var dataChu = List[List[Double]](List[Double](salary, tax.getChurchPayment))
    var dataFun = List[List[Double]](List[Double](salary, tax.getFuneralPayment))
    var dataPen = List[List[Double]](List[Double](salary, tax.getPensionContribution))
    var dataCre = List[List[Double]](List[Double](salary, tax.getTaxCredit))

    for (salary <- 2000 to 100000 by 1000) {
      val tax = new TaxEuro(salary, municipality, age)
      dataSta :+= List[Double](salary, tax.getStateTax)
      dataMun :+= List[Double](salary, tax.getMunicipalityTax)
      dataCou :+= List[Double](salary, tax.getCountyTax)
      dataChu :+= List[Double](salary, tax.getChurchPayment)
      dataFun :+= List[Double](salary, tax.getFuneralPayment)
      dataPen :+= List[Double](salary, tax.getPensionContribution)
      dataCre :+= List[Double](salary, tax.getTaxCredit)
    }

    Json.arr(
      Json.obj(
        "key" -> "Eläkemaksu",
        "values" -> Json.toJson(dataPen)
      ),
      Json.obj(
        "key" -> "Kirkollisvero",
        "values" -> Json.toJson(dataChu)
      ),
      Json.obj(
        "key" -> "Hautajaismaksu",
        "values" -> Json.toJson(dataFun)
      ),
      Json.obj(
        "key" -> "Maakuntavero",
        "values" -> Json.toJson(dataCou)
      ),
      Json.obj(
        "key" -> "Kunnallisvero",
        "values" -> Json.toJson(dataMun)
      ),
      Json.obj(
        "key" -> "Valtion vero",
        "values" -> Json.toJson(dataSta)
      )
    )
  }

  def getNetIncomeData: JsArray = {
    val municipality = "Stockholm"
    val age = 30

    var salary = 1000
    val tax = new TaxEuro(salary, municipality, age)
    var dataNet = List[List[Double]](List[Double](salary, tax.getNetIncome))
    var dataTax = List[List[Double]](List[Double](salary, tax.getTotalTax))


    for (salary <- 2000 to 100000 by 1000) {
      val tax = new TaxEuro(salary, municipality, age)
      dataNet :+= List[Double](salary, tax.getNetIncome)
      dataTax :+= List[Double](salary, tax.getTotalTax)

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
