package models

import scala.math.{floor, round}

package object sv {
  def roundHundreds(value: Double): Double = {
    round(value / 100) * 100
  }

  def roundDownHundreds(value: Double): Double = {
    floor(value / 100) * 100
  }
}