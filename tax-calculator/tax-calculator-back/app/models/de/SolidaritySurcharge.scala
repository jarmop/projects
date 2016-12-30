package models.de

import play.api.libs.json.{Json, JsObject}

class SolidaritySurcharge(incomeTax: Double) {
  var sum: Double = -1
  val minIncomeTax = 972
  val maxIncomeTax = 1340.69
  val maxPercent = 0.055

  def getSum: Double = {
    if (this.sum < 0) {
      this.sum = this.calculateSum
    }
    this.sum
  }

  def calculateSum: Double = {
    if (this.incomeTax < this.minIncomeTax) {
      return 0
    }
    var percent = this.maxPercent
    if (this.incomeTax < this.maxIncomeTax) {
      percent = (this.incomeTax - this.minIncomeTax) / (this.maxIncomeTax - this.minIncomeTax) * this.maxPercent
    }
    percent * this.incomeTax
  }

  def getJson: JsObject = Json.obj(
    "sum" -> this.getSum
  )
}
