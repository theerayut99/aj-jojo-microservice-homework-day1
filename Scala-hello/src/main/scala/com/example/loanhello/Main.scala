package com.example.loanhello

import org.apache.pekko.actor.typed.ActorSystem
import org.apache.pekko.actor.typed.scaladsl.Behaviors
import org.apache.pekko.http.scaladsl.Http
import org.slf4j.LoggerFactory

import scala.concurrent.ExecutionContextExecutor
import scala.util.{Failure, Success}

object Main:
  private val logger = LoggerFactory.getLogger(getClass)

  def main(args: Array[String]): Unit =
    val host = sys.env.getOrElse("HOST", "0.0.0.0")
    val port = sys.env.getOrElse("PORT", "8080").toInt

    given system: ActorSystem[Nothing] = ActorSystem(Behaviors.empty, "scala-hello")
    given ec: ExecutionContextExecutor = system.executionContext

    Http().newServerAt(host, port).bind(Routes.routes).onComplete {
      case Success(binding) =>
        logger.info(s"Server started at http://${binding.localAddress.getHostString}:${binding.localAddress.getPort}")
      case Failure(ex) =>
        logger.error(s"Failed to bind server: ${ex.getMessage}")
        system.terminate()
    }

    sys.addShutdownHook {
      logger.info("Shutting down server...")
      system.terminate()
    }
