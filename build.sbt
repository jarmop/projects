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
  "org.webjars.bower" % "less" % "2.5.0",
  "org.webjars.bower" % "bootstrap" % "3.3.4",
  "org.webjars.bower" % "angular" % "1.4.0-rc.1",
  "org.webjars.bower" % "angular-bootstrap" % "0.13.0",
  "org.webjars" % "d3js" % "3.5.5"
)


fork in run := true

pipelineStages := Seq(digest)
