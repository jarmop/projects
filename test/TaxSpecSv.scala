import models.sv.{TaxableIncome, Tax}
import org.specs2.mutable._
import org.specs2.runner._
import org.junit.runner._

@RunWith(classOf[JUnitRunner])
class TaxSpecSv extends Specification {
  val municipality = "Stockholm"
  val age = 30

  val taxes = Map[Int,Map[String, Double]](
    300000 -> Map(
      "municipalityTax" -> 49822.240000000005,
      "countyTax" -> 34097.799999999996,
      "churchPayment" -> 2761.64,
      "funeralPayment" -> 211.35,
      "earnedIncomeTax" -> 0,
      "pensionContribution" -> 21000,
      "taxCredit" -> 21163
    ),
    500000 -> Map(
      "municipalityTax" -> 86083.92000000001,
      "countyTax" -> 58914.9,
      "churchPayment" -> 4771.62,
      "funeralPayment" -> 365.175,
      "earnedIncomeTax" -> 11340,
      "pensionContribution" -> 32800,
      "taxCredit" -> 24657
    ),
    700000 -> Map(
      "municipalityTax" -> 121443.92000000001,
      "countyTax" -> 83114.9,
      "churchPayment" -> 6731.62,
      "funeralPayment" -> 515.175,
      "earnedIncomeTax" -> 54880,
      "pensionContribution" -> 32800,
      "taxCredit" -> 24657
    )
  )

  for ((k,v) <- taxes) {
    var tax = new Tax(k, municipality, age)
    "Tax " + k should {
      "municipalityTax" in {
        tax.getMunicipalityTax equals(v.get("municipalityTax").get)
      }
      "countyTax" in {
        tax.getCountyTax equals(v.get("countyTax").get)
      }
      "churchPayment" in {
        tax.getChurchPayment equals(v.get("churchPayment").get)
      }
      "funeralPayment" in {
        tax.getFuneralPayment equals(v.get("funeralPayment").get)
      }
      "earnedIncomeTax" in {
        tax.getEarnedIncomeTax equals(v.get("earnedIncomeTax").get)
      }
      "pensionContribution" in {
        tax.getPensionContribution equals(v.get("pensionContribution").get)
      }
      "taxCredit" in {
        tax.getTaxCredit equals(v.get("taxCredit").get)
      }
    }
  }

  val nonTaxables = Map[Int,Double](
    18999 -> 18999.0,
    19000 -> 18900.0,
    44499 -> 18900.0,
    44500 -> 19000.0,
    120999 -> 34200,
    121000 -> 34300,
    139099 -> 34300,
    139100 -> 34200,
    350099 -> 13200,
    350100 -> 13100,
    500000 -> 13100
  )

  "Taxable income" should {
    for ((k,v) <- nonTaxables) {
      var taxableIncome = new TaxableIncome(k)
      "Earned income " + k in {
        taxableIncome.getNonTaxable equals(v)
      }
    }
  }
}