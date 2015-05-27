import models.fi.Tax
import org.specs2.mutable._
import org.specs2.runner._
import org.junit.runner._

@RunWith(classOf[JUnitRunner])
class TestSpec extends Specification {
  val salary = 3000000
  val municipality = "Helsinki"
  val age = 30

  val tax = new Tax(salary, municipality, age)

  "Tax" should {
    "government" in {
      tax.getGovernmentTax equals(98567.5)
    }
    "municipality" in {
      tax.getMunicipalityTax equals(447223.05365033617)
    }
    "YLETax" in {
      tax.getYleTax equals(14300.0)
    }
    "MedicalCareInsurancePayment" in {
      tax.getMedicalCareInsurancePayment equals(31909.969233429398)
    }
    "perDiemPayment" in {
      tax.getPerDiemPayment equals(23400.0)
    }
    "pensionContribution" in {
      tax.getPensionContribution.pp equals(171000.0)
    }
    "unemploymentInsurance" in {
      tax.getUnemploymentInsurance equals(19500.0)
    }
    "churchTax" in {
      tax.getChurchTax equals(24174.21911623439)
    }
    "total tax" in {
      tax.getTotalTax equals(541007.242)
    }
  }
}