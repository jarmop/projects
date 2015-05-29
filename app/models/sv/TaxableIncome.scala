package models.sv

import play.api.libs.json.{Json, JsObject}

class TaxableIncome(earnedIncome: Double) {
  var sum: Double = -1

  def getSum: Double = {
    if (this.sum < 0) {
      this.sum = this.calculateSum
    }

    this.sum
  }

  def getBusinessIncome: Double = {
    0
  }

  def getGeneralDeductions: Double = {
    0
  }

  def getTotalIncome: Double = {
    this.earnedIncome + this.getBusinessIncome - this.getGeneralDeductions
  }

  def getNonTaxable: Double = {
    13100
  }

  // sjöinkomstavdrag = lake deductions ???
  def getLakeDeductions: Double = {
    0
  }

  def getTotalDeductions: Double = {
    this.getGeneralDeductions + this.getNonTaxable + this.getLakeDeductions
  }

  def calculateSum: Double = {
    this.getTotalIncome - this.getTotalDeductions
    /*var taxableIncome = 486900
    if (this.earnedIncome == 300000) {
      taxableIncome = 281800
    } else if (this.earnedIncome == 700000) {
      taxableIncome = 686900
    }
    taxableIncome*/
  }

  def getJson: JsObject = {
    Json.obj(
      "sum" -> this.getSum,
      "income" -> Json.obj(
        "total" -> this.getTotalIncome,
        "earnedIncome"-> this.earnedIncome,
        "businessIncome" -> this.getBusinessIncome
      ),
      "deductions" -> Json.obj(
        "total" -> this.getTotalDeductions,
        "generalDeductions" -> this.getGeneralDeductions,
        "nonTaxable" -> this.getNonTaxable,
        "lakeDeductions" -> this.getLakeDeductions
      )
    )
  }
}
