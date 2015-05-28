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
      "employer" -> 1620537.5,
      "municipalityAndChurch" -> 885900.0,
      "earnedIncomeTaxCredit" -> 205500.0
    )
  )

  /*for ((k,v) <- taxes) {
    var tax = new Tax(k, municipality, age)
    "Tax " + k should {
      "employer" in {
        tax.getEpmloyerTax equals(v.get("employer").get)
      }
      "municipalityAndChurch" in {
        tax.getMunicipalityAndChurch equals(v.get("municipalityAndChurch").get)
      }
      "earnedIncomeTaxCredit" in {
        tax.getEarnedIncomeTaxCredit equals(v.get("earnedIncomeTaxCredit").get)
      }
    }
  }*/
}