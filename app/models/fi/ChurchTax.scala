package models.fi

import play.api.libs.json.{Json, JsObject}

class ChurchTax(salary: Int, municipality: String, church: String = "evangelicLutheran") {
  val taxPercents = Map[String, Map[String, Double]](
    "Helsinki" -> Map[String, Double]("evangelicLutheran" -> 0.01, "orthodox" -> 0.0175),
    "Nivala" -> Map[String, Double]("evangelicLutheran" -> 0.016, "orthodox" -> 0.0195)
  )

  val taxPercent = this.taxPercents.get(this.municipality).get.get(this.church).get

  def getSum: Double = {
    this.taxPercent * this.salary
  }

  def getJson: JsObject = {
    Json.obj(
      "percent" -> this.taxPercent,
      "sum" -> this.getSum
    )
  }
}
