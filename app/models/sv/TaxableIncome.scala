package models.sv

import play.api.Logger
import play.api.libs.json.{Json, JsObject}
import scala.math.floor

class TaxableIncome(earnedIncome: Double) {
  var sum: Double = -1
  var nonTaxable: Double = -1

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
    if (this.nonTaxable < 0) {
      this.nonTaxable = this.calculateNonTaxable
    }
    this.nonTaxable
  }

  def calculateNonTaxable: Double = {
    if (this.earnedIncome < 19000) {
      return this.earnedIncome
    }
    val minimumNonTaxable: Double = 18900
    val level1IncomeStart = 44500
    if (this.earnedIncome < level1IncomeStart) {
      return minimumNonTaxable
    }
    val level1IncomeLimit = 121000
    val level2IncomeStart = 139100
    val maximumNonTaxable: Double = 34300
    if (this.earnedIncome >= level1IncomeLimit && this.earnedIncome < level2IncomeStart) {
      return maximumNonTaxable
    }
    val level2limit = 350100
    if (this.earnedIncome >= level2limit) {
      return 13100
    }
    if (this.earnedIncome < level1IncomeLimit) {
      var level1IncomeChange = 500
      var level1DeductionChange = 100
      val steps1 = floor((this.earnedIncome - level1IncomeStart) / level1IncomeChange) + 1
      return minimumNonTaxable + steps1 * level1DeductionChange
    }
    if (this.earnedIncome < level2limit) {
      val level2IncomeChange = 1000
      val level2DeductionChange = -100
      val steps2 = floor((this.earnedIncome - level2IncomeStart) / level2IncomeChange) + 1
      return maximumNonTaxable + steps2 * level2DeductionChange
    }
    0
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
