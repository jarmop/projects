package services.fi

import models.fi.Tax
import play.api.libs.json.Json

object CompareService {
  def getPercentData: play.api.libs.json.JsArray = {
    val municipality = "Helsinki"
    val age = 30

    val tax = new Tax(1000000, municipality, age)
    var salary = 1000000
    //var data = List[List[Double]](List[Double](salary / 100, tax.getTotalTax / salary * 100))
    var dataGov = List[List[Double]](List[Double](salary / 100, tax.getGovernmentTaxPercent * 100))
    var dataMun = List[List[Double]](List[Double](salary / 100, tax.getMunicipalityTaxPercent * 100))
    var dataPen = List[List[Double]](List[Double](salary / 100, tax.getPensionContributionPercent * 100))
    var dataUnemp = List[List[Double]](List[Double](salary / 100, tax.getUnemploymentInsurancePercent * 100))
    var dataMed = List[List[Double]](List[Double](salary / 100, tax.getMedicalCareInsurancePaymentPercentage * 100))
    var dataPer = List[List[Double]](List[Double](salary / 100, tax.getPerDiemPaymentPercent * 100))
    var dataYle = List[List[Double]](List[Double](salary / 100, tax.getYleTaxPercentage * 100))
    //var net = List[List[Double]](List[Double](salary / 100, (salary - tax.getTotalTax) / salary * 100))

    for (salary <- 1100000 to 10000000 by 100000) {
      val tax = new Tax(salary, municipality, age)
      //data :+= List[Double](salary / 100, tax.getTotalTax / salary * 100)
      dataGov :+= List[Double](salary / 100, tax.getGovernmentTaxPercent * 100)
      dataMun :+= List[Double](salary / 100, tax.getMunicipalityTaxPercent * 100)
      dataPen :+= List[Double](salary / 100, tax.getPensionContributionPercent * 100)
      dataUnemp :+= List[Double](salary / 100, tax.getUnemploymentInsurancePercent * 100)
      dataMed :+= List[Double](salary / 100, tax.getMedicalCareInsurancePaymentPercentage * 100)
      dataPer :+= List[Double](salary / 100, tax.getPerDiemPaymentPercent * 100)
      dataYle :+= List[Double](salary / 100, tax.getYleTaxPercentage * 100)
      //net :+= List[Double](salary / 100, (salary - tax.getTotalTax) / salary * 100)
    }

    Json.arr(
      Json.obj(
        "key" -> "Päivärahamaksu",
        "values" -> Json.toJson(dataPer)
      ),
      Json.obj(
        "key" -> "YLE-vero",
        "values" -> Json.toJson(dataYle)
      ),
      Json.obj(
        "key" -> "Sairaanhoitomaksu",
        "values" -> Json.toJson(dataMed)
      ),
      Json.obj(
        "key" -> "Työttömyysvakuutusmaksut",
        "values" -> Json.toJson(dataUnemp)
      ),
      Json.obj(
        "key" -> "Työeläkemaksut",
        "values" -> Json.toJson(dataPen)
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

  def getSumData: play.api.libs.json.JsArray = {
    val municipality = "Helsinki"
    val age = 30

    val tax = new Tax(1000000, municipality, age)
    var salary = 1000000
    //var data = List[List[Double]](List[Double](salary / 100, tax.getTotalTax / salary * 100))
    var dataGov = List[List[Double]](List[Double](salary / 100, tax.getGovernmentTax / 100))
    var dataMun = List[List[Double]](List[Double](salary / 100, tax.getMunicipalityTax / 100))
    var dataPen = List[List[Double]](List[Double](salary / 100, tax.getPensionContribution / 100))
    var dataUnemp = List[List[Double]](List[Double](salary / 100, tax.getUnemploymentInsurance / 100))
    var dataMed = List[List[Double]](List[Double](salary / 100, tax.getMedicalCareInsurancePayment / 100))
    var dataPer = List[List[Double]](List[Double](salary / 100, tax.getPerDiemPayment / 100))
    var dataYle = List[List[Double]](List[Double](salary / 100, tax.getYleTax / 100))
    //var net = List[List[Double]](List[Double](salary / 100, (salary - tax.getTotalTax) / salary * 100))

    for (salary <- 1100000 to 10000000 by 100000) {
      val tax = new Tax(salary, municipality, age)
      //data :+= List[Double](salary / 100, tax.getTotalTax / salary * 100)
      dataGov :+= List[Double](salary / 100, tax.getGovernmentTax / 100)
      dataMun :+= List[Double](salary / 100, tax.getMunicipalityTax / 100)
      dataPen :+= List[Double](salary / 100, tax.getPensionContribution / 100)
      dataUnemp :+= List[Double](salary / 100, tax.getUnemploymentInsurance / 100)
      dataMed :+= List[Double](salary / 100, tax.getMedicalCareInsurancePayment / 100)
      dataPer :+= List[Double](salary / 100, tax.getPerDiemPayment / 100)
      dataYle :+= List[Double](salary / 100, tax.getYleTax / 100)
      //net :+= List[Double](salary / 100, (salary - tax.getTotalTax) / salary * 100)
    }

    Json.arr(
      Json.obj(
        "key" -> "Päivärahamaksu",
        "values" -> Json.toJson(dataPer)
      ),
      Json.obj(
        "key" -> "YLE-vero",
        "values" -> Json.toJson(dataYle)
      ),
      Json.obj(
        "key" -> "Sairaanhoitomaksu",
        "values" -> Json.toJson(dataMed)
      ),
      Json.obj(
        "key" -> "Työttömyysvakuutusmaksut",
        "values" -> Json.toJson(dataUnemp)
      ),
      Json.obj(
        "key" -> "Työeläkemaksut",
        "values" -> Json.toJson(dataPen)
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
