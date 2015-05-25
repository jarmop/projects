package models.fi

import play.api.libs.json.{Json, JsObject}

class ChurchTax(salary: Int) {
  def getSum: Double = {
    0
  }

  def getJson: JsObject = {
    Json.obj()
  }
}
