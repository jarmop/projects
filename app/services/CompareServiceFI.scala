package services

import play.api.libs.json.{JsArray, Json}
import models.fi.Tax

object CompareServiceFI {
  def getPercentData: JsArray = {
    val municipality = "Helsinki"
    val age = 30

    val tax = new Tax(100000, municipality, age)
    var salary = 100000
    var dataGov = List[List[Double]](List[Double](salary, tax.getGovernmentTaxPercentage))
    var dataMun = List[List[Double]](List[Double](salary, tax.getMunicipalityTaxPercentage))
    var dataPen = List[List[Double]](List[Double](salary, tax.getPensionContributionPercentage))
    var dataUnemp = List[List[Double]](List[Double](salary, tax.getUnemploymentInsurancePercentage))
    var dataMed = List[List[Double]](List[Double](salary, tax.getMedicalCareInsurancePaymentPercentage))
    var dataPer = List[List[Double]](List[Double](salary, tax.getPerDiemPaymentPercentage))
    var dataYle = List[List[Double]](List[Double](salary, tax.getYleTaxPercentage))
    var dataChu = List[List[Double]](List[Double](salary, tax.getChurchTaxPercentage))
    var dataWor = List[List[Double]](List[Double](salary, tax.getWorkIncomeDeductionPercentage))

    for (salary <- 200000 to 10000000 by 100000) {
      val tax = new Tax(salary, municipality, age)
      //data :+= List[Double](salary, tax.getTotalTax / salary))
      dataGov :+= List[Double](salary, tax.getGovernmentTaxPercentage)
      dataMun :+= List[Double](salary, tax.getMunicipalityTaxPercentage)
      dataPen :+= List[Double](salary, tax.getPensionContributionPercentage)
      dataUnemp :+= List[Double](salary, tax.getUnemploymentInsurancePercentage)
      dataMed :+= List[Double](salary, tax.getMedicalCareInsurancePaymentPercentage)
      dataPer :+= List[Double](salary, tax.getPerDiemPaymentPercentage)
      dataYle :+= List[Double](salary, tax.getYleTaxPercentage)
      dataChu :+= List[Double](salary, tax.getChurchTaxPercentage)
      dataWor :+= List[Double](salary, tax.getWorkIncomeDeductionPercentage)
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
      ),
      Json.obj(
        "key" -> "Työtulovähennys",
        "values" -> Json.toJson(dataWor)
      )
    )
  }

  def getSumData: JsArray = {
    val municipality = "Helsinki"
    val age = 30

    val tax = new Tax(100000, municipality, age)
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
      val tax = new Tax(salary, municipality, age)
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
  }
}
