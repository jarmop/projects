name := """tax"""

version := "1.0-SNAPSHOT"

lazy val root = (project in file(".")).enablePlugins(PlayScala, SbtWeb)

scalaVersion := "2.11.1"

libraryDependencies ++= Seq(
  jdbc,
  anorm,
  cache,
  ws,
  "org.webjars" %% "webjars-play" % "2.3.0-2",
  "org.webjars" % "less" % "2.5.0",
  "org.webjars" % "bootstrap" % "3.3.4",
  "org.webjars" % "angularjs" % "2.0.0-alpha.19",
  "org.webjars" % "angular-ui-bootstrap" % "0.13.0",
  "org.webjars" % "d3js" % "3.5.5"
)


fork in run := true

pipelineStages := Seq(rjs, digest, gzip)
