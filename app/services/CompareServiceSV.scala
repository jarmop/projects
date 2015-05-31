package services

import models.sv.Tax
import play.api.libs.json.{Json, JsArray}

object CompareServiceSV {
  def getPercentData: JsArray = {
    val municipality = "Stockholm"
    val age = 30

    var salary = 100000
    val tax = new Tax(salary, municipality, age)
    var dataSta = List[List[Double]](List[Double](salary, tax.getStateTaxPercentage))
    var dataMun = List[List[Double]](List[Double](salary, tax.getMunicipalityTaxPercentage))
    var dataCou = List[List[Double]](List[Double](salary, tax.getCountyTaxPercentage))
    var dataChu = List[List[Double]](List[Double](salary, tax.getChurchPaymentPercentage))
    var dataFun = List[List[Double]](List[Double](salary, tax.getFuneralPaymentPercentage))
    var dataPen = List[List[Double]](List[Double](salary, tax.getPensionContributionPercentage))

    for (salary <- 200000 to 1000000 by 100000) {
      val tax = new Tax(salary, municipality, age)
      dataSta :+= List[Double](salary, tax.getStateTaxPercentage)
      dataMun :+= List[Double](salary, tax.getMunicipalityTaxPercentage)
      dataCou :+= List[Double](salary, tax.getCountyTaxPercentage)
      dataChu :+= List[Double](salary, tax.getChurchPaymentPercentage)
      dataFun :+= List[Double](salary, tax.getFuneralPaymentPercentage)
      dataPen :+= List[Double](salary, tax.getPensionContributionPercentage)
    }

    Json.arr(
      Json.obj(
        "key" -> "Valtion vero",
        "values" -> Json.toJson(dataSta)
      ),
      Json.obj(
        "key" -> "Kunnallisvero",
        "values" -> Json.toJson(dataMun)
      ),
      Json.obj(
        "key" -> "Maakuntavero",
        "values" -> Json.toJson(dataCou)
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
        "key" -> "Eläkemaksu",
        "values" -> Json.toJson(dataPen)
      )
    )
  }

  /*def getSumData: JsArray = {
    val municipality = "Helsinki"
    val age = 30

    val tax = new fi.Tax(100000, municipality, age)
    var salary = 100000
    var dataGov = List[List[Double]](List[Double](salary, tax.getGovernmentTax))
    var dataMun = List[List[Double]](List[Double](salary, tax.getMunicipalityTax))
    var dataPen = List[List[Double]](List[Double](salary, tax.getPensionContribution))
    var dataUnemp = List[List[Double]](List[Double](salary, tax.getUnemploymentInsurance))
    var dataMed = List[List[Double]](List[Double](salary, tax.getMedicalCareInsurancePayment))
    var dataPer = List[List[Double]](List[Double](salary, tax.getPerDiemPayment))
    var dataYle = List[List[Double]](List[Double](salary, tax.getYleTax))
    var dataChu = List[List[Double]](List[Double](salary, tax.getChurchTax))

    for (salary <- 200000 to 10000000 by 100000) {
      val tax = new fi.Tax(salary, municipality, age)
      //data :+= List[Double](salary / 100, tax.getTotalTax / salary * 100)
      dataGov :+= List[Double](salary, tax.getGovernmentTax)
      dataMun :+= List[Double](salary, tax.getMunicipalityTax)
      dataPen :+= List[Double](salary, tax.getPensionContribution)
      dataUnemp :+= List[Double](salary, tax.getUnemploymentInsurance)
      dataMed :+= List[Double](salary, tax.getMedicalCareInsurancePayment)
      dataPer :+= List[Double](salary, tax.getPerDiemPayment)
      dataYle :+= List[Double](salary, tax.getYleTax)
      dataChu :+= List[Double](salary, tax.getChurchTax)
    }

    Json.arr(
      Json.obj(
        "key" -> "Työttömyysvakuutusmaksut",
        "values" -> Json.toJson(dataUnemp)
      ),
      Json.obj(
        "key" -> "Työeläkemaksut",
        "values" -> Json.toJson(dataPen)
      ),
      Json.obj(
        "key" -> "Päivärahamaksu",
        "values" -> Json.toJson(dataPer)
      ),
      Json.obj(
        "key" -> "Sairaanhoitomaksu",
        "values" -> Json.toJson(dataMed)
      ),
      Json.obj(
        "key" -> "YLE-vero",
        "values" -> Json.toJson(dataYle)
      ),
      Json.obj(
        "key" -> "Kirkollisvero",
        "values" -> Json.toJson(dataChu)
      ),
      Json.obj(
        "key" -> "Kunnallisvero",
        "values" -> Json.toJson(dataMun)
      ),
      Json.obj(
        "key" -> "Valtion vero",
        "values" -> Json.toJson(dataGov)
      )
    )
  }*/
}
