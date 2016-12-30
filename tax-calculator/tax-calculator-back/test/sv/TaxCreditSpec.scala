import models.sv.TaxCredit
import org.specs2.mutable._
import org.specs2.runner._
import org.junit.runner._

@RunWith(classOf[JUnitRunner])
class TaxCreditSpec extends Specification {
  val municipalityPercent = 0.2978

  case class datum(earnedIncome: Int, nonTaxable: Double, pensionContribution: Double, expected: Double)

  val data = List[datum](
    datum(20000, 18900, 1400, 0),
    datum(30000, 18900, 2100, 1205.58),
    datum(62699, 22600, 4400, 7512),
    datum(90000, 28100, 6300, 8585.770548),
    datum(240000, 24200, 16800, 17393.268086)
  )

  "TaxCredit" should {
    for (datum <- data) {
      var taxCredit = new TaxCredit(datum.earnedIncome, datum.nonTaxable, this.municipalityPercent, datum.pensionContribution)
      "Earned income " + datum.earnedIncome in {
        taxCredit.getSum.pp equals(datum.expected)
      }
    }
  }
}