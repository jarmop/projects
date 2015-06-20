package models

import services.Data

import scala.collection.mutable.ListBuffer

trait TaxObjectTrait {
  protected val subTaxNames: List[String]

  def getDataList: ListBuffer[Data] = {
    val dataList = new ListBuffer[Data]
    for (subTaxName <- this.subTaxNames) {
      dataList.append(Data(subTaxName, new ListBuffer[List[Double]]))
    }
    dataList
  }
}
