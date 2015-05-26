package services.fi

import models.fi.Tax
import play.api.libs.json.{JsArray, Json}
import scala.math._

object CompareService {
  def getPercentData: JsArray = {
    val municipality = "Helsinki"
    val age = 30

    val tax = new Tax(1000000, municipality, age)
    var salary = 1000000
    //var data = List[List[Double]](List[Double](salary / 100, tax.getTotalTax / salary * 100))
    var dataGov = List[List[Double]](List[Double](salary / 100, tax.getGovernmentTaxPercent * 100))
    var dataMun = List[List[Double]](List[Double](salary / 100, tax.getMunicipalityTaxPercent * 100))
    var dataPen = List[List[Double]](List[Double](salary / 100, tax.getPensionContributionPercentage * 100))
    var dataUnemp = List[List[Double]](List[Double](salary / 100, tax.getUnemploymentInsurancePercentage * 100))
    var dataMed = List[List[Double]](List[Double](salary / 100, tax.getMedicalCareInsurancePaymentPercentage * 100))
    var dataPer = List[List[Double]](List[Double](salary / 100, tax.getPerDiemPaymentPercentage * 100))
    var dataYle = List[List[Double]](List[Double](salary / 100, tax.getYleTaxPercentage * 100))
    var dataChu = List[List[Double]](List[Double](salary / 100, tax.getChurchTaxPercentage * 100))

    for (salary <- 1100000 to 10000000 by 100000) {
      val tax = new Tax(salary, municipality, age)
      //data :+= List[Double](salary / 100, tax.getTotalTax / salary * 100)
      dataGov :+= List[Double](salary / 100, tax.getGovernmentTaxPercent * 100)
      dataMun :+= List[Double](salary / 100, tax.getMunicipalityTaxPercent * 100)
      dataPen :+= List[Double](salary / 100, tax.getPensionContributionPercentage * 100)
      dataUnemp :+= List[Double](salary / 100, tax.getUnemploymentInsurancePercentage * 100)
      dataMed :+= List[Double](salary / 100, tax.getMedicalCareInsurancePaymentPercentage * 100)
      dataPer :+= List[Double](salary / 100, tax.getPerDiemPaymentPercentage * 100)
      dataYle :+= List[Double](salary / 100, tax.getYleTaxPercentage * 100)
      dataChu :+= List[Double](salary / 100, tax.getChurchTaxPercentage * 100)
    }

    Json.arr(
      Json.obj(
        "key" -> "Kirkollisvero",
        "values" -> Json.toJson(dataChu)
      ),
      Json.obj(
        "key" -> "Päivärahamaksu",
        "values" -> Json.toJson(dataPer)
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
        "key" -> "YLE-vero",
        "values" -> Json.toJson(dataYle)
      ),
      Json.obj(
        "key" -> "Sairaanhoitomaksu",
        "values" -> Json.toJson(dataMed)
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

  def getSumData: JsArray = {
    val municipality = "Helsinki"
    val age = 30

    val tax = new Tax(1000000, municipality, age)
    var salary = 1000000
    //var data = List[List[Double]](List[Double](this.formatSum(salary), tax.getTotalTax / salary * 100))
    var dataGov = List[List[Double]](List[Double](this.formatSum(salary), this.formatSum(tax.getGovernmentTax)))
    var dataMun = List[List[Double]](List[Double](this.formatSum(salary), this.formatSum(tax.getMunicipalityTax)))
    var dataPen = List[List[Double]](List[Double](this.formatSum(salary), this.formatSum(tax.getPensionContribution)))
    var dataUnemp = List[List[Double]](List[Double](this.formatSum(salary), this.formatSum(tax.getUnemploymentInsurance)))
    var dataMed = List[List[Double]](List[Double](this.formatSum(salary), this.formatSum(tax.getMedicalCareInsurancePayment)))
    var dataPer = List[List[Double]](List[Double](this.formatSum(salary), this.formatSum(tax.getPerDiemPayment)))
    var dataYle = List[List[Double]](List[Double](this.formatSum(salary), this.formatSum(tax.getYleTax)))
    var dataChu = List[List[Double]](List[Double](this.formatSum(salary), this.formatSum(tax.getChurchTax)))

    for (salary <- 1100000 to 10000000 by 100000) {
      val tax = new Tax(salary, municipality, age)
      //data :+= List[Double](salary / 100, tax.getTotalTax / salary * 100)
      dataGov :+= List[Double](this.formatSum(salary), this.formatSum(tax.getGovernmentTax))
      dataMun :+= List[Double](this.formatSum(salary), this.formatSum(tax.getMunicipalityTax))
      dataPen :+= List[Double](this.formatSum(salary), this.formatSum(tax.getPensionContribution))
      dataUnemp :+= List[Double](this.formatSum(salary), this.formatSum(tax.getUnemploymentInsurance))
      dataMed :+= List[Double](this.formatSum(salary), this.formatSum(tax.getMedicalCareInsurancePayment))
      dataPer :+= List[Double](this.formatSum(salary), this.formatSum(tax.getPerDiemPayment))
      dataYle :+= List[Double](this.formatSum(salary), this.formatSum(tax.getYleTax))
      dataChu :+= List[Double](this.formatSum(salary), this.formatSum(tax.getChurchTax))
    }

    Json.arr(
      Json.obj(
        "key" -> "Kirkollisvero",
        "values" -> Json.toJson(dataChu)
      ),
      Json.obj(
        "key" -> "Päivärahamaksu",
        "values" -> Json.toJson(dataPer)
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
        "key" -> "YLE-vero",
        "values" -> Json.toJson(dataYle)
      ),
      Json.obj(
        "key" -> "Sairaanhoitomaksu",
        "values" -> Json.toJson(dataMed)
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

  private def formatSum(sum: Double): Double = {
    sum
  }
}
