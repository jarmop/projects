import models.sv.Tax
import org.specs2.mutable._
import org.specs2.runner._
import org.junit.runner._

@RunWith(classOf[JUnitRunner])
class TaxSpecSv extends Specification {
  val municipality = "Stockholm"
  val age = 30

  val taxes = Map[Int,Map[String, Double]](
    3000000 -> Map(
      "municipalityTax" -> 49822.240000000005,
      "countyTax" -> 34097.799999999996,
      "churchPayment" -> 2761.64,
      "funeralPayment" -> 211.35
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
    }
  }
}