package object models {
  def substractUntilZero(value: Double, substraction: Double): Double = {
    if (substraction < value) value - substraction else 0
  }
}