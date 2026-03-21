lazy val root = (project in file("."))
  .settings(
    name := "scala-hello",
    version := "1.0.0",
    scalaVersion := "3.3.7",
    Compile / mainClass := Some("com.example.loanhello.Main"),
    libraryDependencies ++= Seq(
      "org.apache.pekko" %% "pekko-actor-typed"   % "1.1.3",
      "org.apache.pekko" %% "pekko-stream"        % "1.1.3",
      "org.apache.pekko" %% "pekko-http"          % "1.1.0",
      "org.apache.pekko" %% "pekko-http-spray-json" % "1.1.0",
      "io.spray"         %% "spray-json"          % "1.3.6",
      "ch.qos.logback"    % "logback-classic"     % "1.5.16",
      "net.logstash.logback" % "logstash-logback-encoder" % "8.0",
      "org.slf4j"          % "slf4j-api"          % "2.0.16"
    ),
    assembly / mainClass := Some("com.example.loanhello.Main"),
    assembly / assemblyJarName := "app.jar",
    assembly / assemblyMergeStrategy := {
      case PathList("META-INF", "versions", _*) => MergeStrategy.first
      case PathList("META-INF", "MANIFEST.MF")  => MergeStrategy.discard
      case PathList("META-INF", _*)             => MergeStrategy.first
      case "reference.conf"                     => MergeStrategy.concat
      case "application.conf"                   => MergeStrategy.concat
      case x if x.endsWith("module-info.class") => MergeStrategy.discard
      case x                                    => MergeStrategy.first
    }
  )
