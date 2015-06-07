package models.de

import play.api.libs.json.{Json, JsObject}

class ChurchTax(incomeTax: Double) {
  val percent = 0.09
  var sum: Double = -1

  def getSum: Double = {
    if (this.sum < 0) {
      this.sum = this.calculateSum
    }
    this.sum
  }

  def calculateSum: Double = {
    this.percent * this.incomeTax
  }

  def getJson: JsObject = Json.obj(
    "sum" -> this.getSum
  )
}
