import models.sv.{PensionContribution}
import org.specs2.mutable._
import org.specs2.runner._
import org.junit.runner._

@RunWith(classOf[JUnitRunner])
class PensionContributionSpec extends Specification {
  val pensionContributions = Map[Int,Double](
    10000 -> 0,
    18823 -> 0,
    18824 -> 1300,
    50000 -> 3500,
    65000 -> 4500,
    200000 -> 14000,
    300000 -> 21000,
    467899 -> 32700,
    467900 -> 32800,
    1000000 -> 32800
  )

  "pensionContribution" should {
    for ((k,v) <- pensionContributions) {
      var pensionContribution = new PensionContribution(k)
      "Earned income " + k in {
        pensionContribution.getSum equals(v)
      }
    }
  }
}