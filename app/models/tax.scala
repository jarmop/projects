package models

import play.api.libs.json._

case class MunicipalityTax(salary: Float, municipality: String, age: Int)

case class Tax(salary: Float, municipality: String, age: Int, municipalityTax: MunicipalityTax) {
  //var salary = salary



  /*def toJson = {
    JsObject(Seq(
      "salary" -> Json.toJson(salary),
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
  }*/


  def this(salary: Float, municipality: String, age: Int) {
    this(salary, municipality, age, MunicipalityTax(salary, municipality, age))
  }
}

object MunicipalityTax {
  implicit val municipalityWrites = Json.writes[MunicipalityTax]
}

object Tax {
  /*implicit val taxWrites = new Writes[Tax] {
    def writes(tax: Tax) = Json.obj(
      "salary" -> tax.salary,
      "municipality" -> tax.municipality,
      "age" -> tax.age,
      "municipalityTax" -> Json.toJson(tax.municipalityTax)
    )
  }*/



  //implicit val municipalityWrites = Json.writes[MunicipalityTax]

  implicit val taxWrites = Json.writes[Tax]

}




