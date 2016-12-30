package sv

import models.sv.Tax
import org.junit.runner._
import org.specs2.mutable._
import org.specs2.runner._

@RunWith(classOf[JUnitRunner])
class TaxSpec extends Specification {
  val municipality = "Stockholm"
  val age = 30

  val taxes = Map[Int,Map[String, Double]](
    300000 -> Map(
      "municipalityTax" -> 37687.67874167408,
      "countyTax" -> 25793.03805284255,
      "churchPayment" -> 2089.022916676504,
      "funeralPayment" -> 159.8742028068753,
      "stateTax" -> 0,
      "pensionContribution" -> 21000,
      "taxCredit" -> 21163.416085999997
    ),
    500000 -> Map(
      "municipalityTax" -> 72939.10789596391,
      "countyTax" -> 49918.73334508842,
      "churchPayment" -> 4043.0048494369134,
      "funeralPayment" -> 309.4136364364985,
      "stateTax" -> 9321.889207605283,
      "pensionContribution" -> 32800,
      "taxCredit" -> 24656.9466
    ),
    700000 -> Map(
      "municipalityTax" -> 110215.58190484377,
      "countyTax" -> 75430.34734437836,
      "churchPayment" -> 6109.23474359428,
      "funeralPayment" -> 467.54347527507247,
      "stateTax" -> 49403.84296686536,
      "pensionContribution" -> 32800,
      "taxCredit" -> 24656.9466
    )
  )

  for ((k,v) <- taxes) {
    var tax = new Tax(k, municipality, age)
    "SV Tax " + k should {
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
      "stateTax" in {
        tax.getStateTax equals(v.get("stateTax").get)
      }
      "pensionContribution" in {
        tax.getPensionContribution equals(v.get("pensionContribution").get)
      }
      /*"taxCredit" in {
        tax.getTaxCredit equals(v.get("taxCredit").get)
      }*/
    }
  }
}