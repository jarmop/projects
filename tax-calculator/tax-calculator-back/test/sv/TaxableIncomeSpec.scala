import models.sv.{TaxableIncome, Tax}
import org.specs2.mutable._
import org.specs2.runner._
import org.junit.runner._

@RunWith(classOf[JUnitRunner])
class TaxableIncomeSpec extends Specification {
  val municipality = "Stockholm"
  val age = 30

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