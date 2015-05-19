package controllers

import controllers.Application._
import models.Tax
import play.api.libs.json.Json
import play.api.mvc._

object Compare extends Controller {

  def index = Action {
    val assets = List[String](
      "javascripts/compare/CompareController.js",
      "javascripts/compare/CompareService.js"
    )

    Ok(views.html.compare("Vertaa", assets))
  }

  def data = Action {
    val municipality = "Helsinki"
    val age = 30

    val tax = new Tax(1000000, municipality, age)
    var salary = 1000000
    //var data = List[List[Double]](List[Double](salary / 100, tax.getTotalTax / salary * 100))
    var dataGov = List[List[Double]](List[Double](salary / 100, tax.getGovernmentTaxPercent * 100))
    var dataMun = List[List[Double]](List[Double](salary / 100, tax.getMunicipalityTaxPercent * 100))
    var dataMed = List[List[Double]](List[Double](salary / 100, tax.getMedicalCareInsurancePaymentPercent * 100))
    var dataPer = List[List[Double]](List[Double](salary / 100, tax.getPerDiemPaymentPercent * 100))
    var dataYle = List[List[Double]](List[Double](salary / 100, tax.getYleTaxPercent * 100))
    //var net = List[List[Double]](List[Double](salary / 100, (salary - tax.getTotalTax) / salary * 100))

    for (salary <- 1100000 to 10000000 by 100000) {
      val tax = new Tax(salary, municipality, age)
      //data :+= List[Double](salary / 100, tax.getTotalTax / salary * 100)
      dataGov :+= List[Double](salary / 100, tax.getGovernmentTaxPercent * 100)
      dataMun :+= List[Double](salary / 100, tax.getMunicipalityTaxPercent * 100)
      dataMed :+= List[Double](salary / 100, tax.getMedicalCareInsurancePaymentPercent * 100)
      dataPer :+= List[Double](salary / 100, tax.getPerDiemPaymentPercent * 100)
      dataYle :+= List[Double](salary / 100, tax.getYleTaxPercent * 100)
      //net :+= List[Double](salary / 100, (salary - tax.getTotalTax) / salary * 100)
    }

    Ok(Json.arr(
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
        "key" -> "Kunnallisvero",
        "values" -> Json.toJson(dataMun)
      ),
      Json.obj(
        "key" -> "Valtion vero",
        "values" -> Json.toJson(dataGov)
      )
    ))
  }
}
