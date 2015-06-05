package models

import play.api.libs.json.JsObject

trait TaxTrait {
  def getJson: JsObject
}
