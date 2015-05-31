package models

import scala.math.{floor, round}

package object sv {
  def roundHundreds(value: Double): Double = {
    round(value / 100) * 100
  }

  def roundHundredsSpecial50(value: Double): Double = {
    if (value % 50 == 0) {
      return roundDownHundreds(value)
    }
    roundHundreds(value)
  }

  def roundDownHundreds(value: Double): Double = {
    floor(value / 100) * 100
  }
}