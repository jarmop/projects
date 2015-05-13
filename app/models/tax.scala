package models

import play.api.libs.json._

case class MunicipalityTax(salary: Float, municipality: String, age: Int)

class Tax(salary: Float, municipality: String, age: Int, municipalityTax: MunicipalityTax) {
  def toJson = {
    JsObject(Seq(
      "name" -> JsString("Watership Down"),
      "location" -> JsObject(Seq("lat" -> JsNumber(51.235685), "long" -> JsNumber(-1.309197))),
      "residents" -> JsArray(Seq(
        JsObject(Seq(
          "name" -> JsString("Fiver"),
          "age" -> JsNumber(4),
          "role" -> JsNull
        )),
        JsObject(Seq(
          "name" -> JsString("Bigwig"),
          "age" -> JsNumber(6),
          "role" -> JsString("Owsla")
        ))
      ))
    ))
  }


  def this(salary: Float, municipality: String, age: Int) {
    this(salary, municipality, age, MunicipalityTax(salary, municipality, age))
  }
}


