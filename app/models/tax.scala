package models

import play.api.libs.json.{Json, Writes}

case class Tax(salary: Int, municipality: String, age: Int) {
  private val incomeDeduction: Double = 62000
  private val pensionContributionTyelSub53Percent = 0.057
  private val pensionContributionTyel53Percent = 0.072
  private val unemploymentInsurancePercent = 0.0065
  private val allowancePaymentTyelPercent = 0.0078

  private var commonDeduction = Map[String, Double](
    "incomeDeduction" -> this.incomeDeduction,
    "pensionContribution" -> this.salary * this.getPensionContributionTyelPercent(),
    "unemploymentInsurance" -> this.salary * this.unemploymentInsurancePercent,
    "allowancePayment" -> this.salary * this.allowancePaymentTyelPercent
  )
  commonDeduction += "total" -> commonDeduction.foldLeft(0.0){  case (a, (k, v)) => a+v  }

  private val governmentTax: GovernmentTax = GovernmentTax(salary, this.incomeDeduction, this.commonDeduction.get("total").get)
  private val municipalityTax: MunicipalityTax = MunicipalityTax(salary, municipality, age, this.incomeDeduction, this.commonDeduction.get("total").get)

  private def getPensionContributionTyelPercent(): Double = {
    if (this.age < 53) {
      return this.pensionContributionTyelSub53Percent;
    } else {
      return this.pensionContributionTyel53Percent;
    }
  }


}

object Tax {
  implicit val taxWrites = new Writes[Tax] {
    def writes(tax: Tax) = Json.obj(
      "municipalityTax" -> Json.toJson(tax.municipalityTax),
      "governmentTax" -> Json.obj(
        "tax" -> tax.salary / 5
      ),
      "commonDeduction" -> tax.commonDeduction
    )
  }
}