name := """tax"""

version := "1.0-SNAPSHOT"

lazy val root = (project in file(".")).enablePlugins(PlayScala, SbtWeb)

scalaVersion := "2.11.6"

libraryDependencies ++= Seq(
  jdbc,
  anorm,
  cache,
  ws,
  "org.reactivemongo" %% "play2-reactivemongo" % "0.10.5.0.akka23",
  "org.webjars" %% "webjars-play" % "2.3.0-2",
  "org.webjars" % "less" % "2.5.0",
  "org.webjars" % "bootstrap" % "3.3.4",
  "org.webjars" % "angularjs" % "1.3.15",
  "org.webjars" % "angular-ui-bootstrap" % "0.13.0",
  "org.webjars" % "d3js" % "3.5.5",
  "org.webjars" % "jquery" % "2.1.4",
  "org.webjars" % "angularjs-nvd3-directives" % "0.0.7-1",
  "org.seleniumhq.selenium" % "selenium-java" % "2.45.0" % "test"
)


fork in run := true

pipelineStages := Seq(rjs, digest, gzip)
