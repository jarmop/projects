package models.sv

import play.api.libs.json.{Json, JsObject}

class MunicipalityTax(salary: Int, municipality: String, age: Int) {
  val municipalityPercents = Map[String, Double]("Stockholm" -> 0.1768)
  val countyPercents = Map[String, Double]("Stockholm" -> 0.1210)
  val churchPercents = Map[String, Double]("Adolf Fred." -> 0.0098)
  val churches = Map[String, List[String]]("Stockholm" -> List[String]("Adolf Fred."))
  val funeralPercents = Map[String, Double]("Stockholm" -> 0.1210)

  def getSum: Double = {
    0.0
  }

  def getJson: JsObject = {
    Json.obj(
      "sum" -> this.getSum
    )
  }
}
