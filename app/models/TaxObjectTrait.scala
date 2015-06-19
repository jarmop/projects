package models

import services.Data

trait TaxObjectTrait {
  def getDataList: List[Data]
}
