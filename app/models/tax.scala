package models

import play.api.libs.json.Json

case class Tax(salary: Float = 30000, municipality: String, age: Int)

object Taxen {

  //case class Book(name: String, author: String)

  implicit val taxWrites = Json.writes[Tax]
  //implicit val bookReads = Json.reads[Book]

  //var books = List(Book("TAOCP", "Knuth"), Book("SICP", "Sussman, Abelson"))

  //var taxip = Tax("Helsinki")

  //def addBook(b: Book) = books = books ::: List(b)
}