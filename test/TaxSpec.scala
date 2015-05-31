import models.fi.Tax
import org.specs2.mutable._
import org.specs2.runner._
import org.junit.runner._

@RunWith(classOf[JUnitRunner])
class TaxSpec extends Specification {
  val municipality = "Helsinki"
  val age = 30

  val taxes = Map[Int,Map[String, Double]](
    100000 -> Map(
      "government" -> 0.0,
      "municipality" -> 0.0,
      "YLETax" -> 0.0,
      "MedicalCareInsurancePayment" -> 0.0,
      "perDiemPayment" -> 780.0,
      "pensionContribution" -> 5700.0,
      "unemploymentInsurance" -> 650.0,
      "churchTax" -> 0.0,
      "totalTax" -> 780.0
    ),
    1000000 -> Map(
      "government" -> 0.0,
      "municipality" -> 0.0,
      "YLETax" -> 6378.4,
      "MedicalCareInsurancePayment" -> 0.0,
      "perDiemPayment" -> 7800.0,
      "pensionContribution" -> 57000.0,
      "unemploymentInsurance" -> 6500.0,
      "churchTax" -> 0.0,
      "totalTax" -> 14178.4
    ),
    3000000 -> Map(
      "government" -> 98567.5,
      "municipality" -> 447223.05365033617,
      "YLETax" -> 14300.0,
      "MedicalCareInsurancePayment" -> 31909.969233429398,
      "perDiemPayment" -> 23400.0,
      "pensionContribution" -> 171000.0,
      "unemploymentInsurance" -> 19500.0,
      "churchTax" -> 24174.21911623439,
      "totalTax" -> 541007.242
    ),
    10000000 -> Map(
      "government" -> 1620537.5,
      "municipality" -> 1706625.0,
      "YLETax" -> 14300.0,
      "MedicalCareInsurancePayment" -> 121770.0,
      "perDiemPayment" -> 78000.0,
      "pensionContribution" -> 570000.0,
      "unemploymentInsurance" -> 65000.0,
      "churchTax" -> 92250.0,
      "totalTax" -> 3610638.5
    )
  )

  for ((k,v) <- taxes) {
    var tax = new Tax(k, municipality, age)
    "Tax " + k should {
      "government" in {
        tax.getGovernmentTax equals(v.get("government").get)
      }
      "municipality" in {
        tax.getMunicipalityTax equals(v.get("municipality").get)
      }
      "YLETax" in {
        tax.getYleTax equals(v.get("YLETax").get)
      }
      "MedicalCareInsurancePayment" in {
        tax.getMedicalCareInsurancePayment equals(v.get("MedicalCareInsurancePayment").get)
      }
      "perDiemPayment" in {
        tax.getPerDiemPayment equals(v.get("perDiemPayment").get)
      }
      "pensionContribution" in {
        tax.getPensionContribution equals(v.get("pensionContribution").get)
      }
      "unemploymentInsurance" in {
        tax.getUnemploymentInsurance equals(v.get("unemploymentInsurance").get)
      }
      "churchTax" in {
        tax.getChurchTax equals(v.get("churchTax").get)
      }
      "totalTax" in {
        tax.getTotalTax equals(v.get("totalTax").get)
      }
    }
  }
}