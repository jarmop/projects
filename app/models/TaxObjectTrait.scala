package models

import services.Data

import scala.collection.mutable.ListBuffer

trait TaxObjectTrait {
  protected val valueNames: List[String]

  def getDataList: ListBuffer[Data] = {
    val dataList = new ListBuffer[Data]
    for (valueName <- this.valueNames) {
      dataList.append(Data(valueName, new ListBuffer[List[Double]]))
    }
    dataList
  }
}
