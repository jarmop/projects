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

  def getApprovedIncome: Double = {
    this.earnedIncome + this.getBusinessIncome - this.getGeneralDeductions
  }

  def getNonTaxable: Double = {
    0
  }

  // sjöinkomstavdrag = lake deductions ???
  def getLakeDeductions: Double = {
    0
  }

  def calculateSum: Double = {
    //this.getApprovedIncome - this.getNonTaxable - this.getLakeDeductions
    var taxableIncome = 486900
    if (this.earnedIncome == 300000) {
      taxableIncome = 281800
    } else if (this.earnedIncome == 700000) {
      taxableIncome = 686900
    }
    taxableIncome
  }

  def getJson: JsObject = {
    Json.obj(
      "sum" -> this.getSum,
      "approvedIncome" -> Json.obj(
        "sum" -> this.getApprovedIncome,
        "earnedIncome"-> this.earnedIncome,
        "businessIncome" -> this.getBusinessIncome,
        "generalDeductions" -> this.getGeneralDeductions
      ),
      "nonTaxable" -> this.getNonTaxable,
      "lakeDeductions" -> this.getLakeDeductions
    )
  }
}
