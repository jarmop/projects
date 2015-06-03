import models.fi.Tax
import org.specs2.mutable._
import org.specs2.runner._
import org.junit.runner._

@RunWith(classOf[JUnitRunner])
class TaxSpec extends Specification {
  val municipality = "Helsinki"
  val age = 30

  val taxes = Map[Int,Map[String, Double]](
    /*1000 -> Map(
      "government" -> 0.0,
      "municipality" -> 0.0,
      "YLETax" -> 0.0,
      "MedicalCareInsurancePayment" -> 0.0,
      "perDiemPayment" -> 7.8,
      "pensionContribution" -> 57.0,
      "unemploymentInsurance" -> 6.5,
      "churchTax" -> 0.0,
      "totalTax" -> 71.3
    ),
    10000 -> Map(
      "government" -> 0.0,
      "municipality" -> 0.0,
      "YLETax" -> 63.784,
      "MedicalCareInsurancePayment" -> 0.0,
      "perDiemPayment" -> 78.0,
      "pensionContribution" -> 570.0,
      "unemploymentInsurance" -> 65.0,
      "churchTax" -> 0.0,
      "totalTax" -> 776.784
    ),*/
    30000 -> Map(
      "government" -> 985.675,
      "municipality" -> 4472.2305365033617,
      "YLETax" -> 143.0,
      "MedicalCareInsurancePayment" -> 319.09969233429398,
      "perDiemPayment" -> 234.0,
      "pensionContribution" -> 1710.0,
      "unemploymentInsurance" -> 195.0,
      "churchTax" -> 241.7421911623439,
      "totalTax" -> 7315.07242
    )/*,
    100000 -> Map(
      "government" -> 16205.375,
      "municipality" -> 17066.25,
      "YLETax" -> 143.0,
      "MedicalCareInsurancePayment" -> 1217.70,
      "perDiemPayment" -> 780.0,
      "pensionContribution" -> 5700.0,
      "unemploymentInsurance" -> 650.0,
      "churchTax" -> 922.50,
      "totalTax" -> 42456.385
    )*/
  )

  for ((k,v) <- taxes) {
    var tax = new Tax(k, municipality, age)
    "FI Tax " + k should {
      "government" in {
        tax.getGovernmentTax.pp equals(v.get("government").get)
      }
      "municipality" in {
        tax.getMunicipalityTax.pp equals(v.get("municipality").get)
      }
      "YLETax" in {
        tax.getYleTax.pp equals(v.get("YLETax").get)
      }
      "MedicalCareInsurancePayment" in {
        tax.getMedicalCareInsurancePayment.pp equals(v.get("MedicalCareInsurancePayment").get)
      }
      "perDiemPayment" in {
        tax.getPerDiemPayment.pp equals(v.get("perDiemPayment").get)
      }
      "pensionContribution" in {
        tax.getPensionContribution.pp equals(v.get("pensionContribution").get)
      }
      "unemploymentInsurance" in {
        tax.getUnemploymentInsurance.pp equals(v.get("unemploymentInsurance").get)
      }
      "churchTax" in {
        tax.getChurchTax.pp equals(v.get("churchTax").get)
      }
      "totalTax" in {
        tax.getTotalTax.pp equals(v.get("totalTax").get)
      }
    }
  }
}