use anyhow::{anyhow, Context, Result};
use clap::{Parser, Subcommand};
use std::collections::{BTreeMap, HashSet};
use std::process::{Command, Stdio};

#[derive(Debug, Clone)]
struct ServiceConfig {
    key: &'static str,
    container_name: &'static str,
    image: &'static str,
    ports: Vec<PortMap>,
    envs: Vec<(&'static str, &'static str)>,
}

#[derive(Debug, Clone)]
struct PortMap {
    host: &'static str,
    container: &'static str,
}

#[derive(Parser, Debug)]
#[command(name = "dockrun")]
#[command(version = "0.1.0")]
#[command(about = "Run all project Docker containers with one command on WSL2")]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand, Debug)]
enum Commands {
    /// Start all services or selected services
    Up {
        /// Run only selected services, comma-separated or repeated
        #[arg(short, long, value_delimiter = ',')]
        services: Vec<String>,

        /// Remove existing container before re-running
        #[arg(long, default_value_t = false)]
        force_recreate: bool,
    },

    /// Stop and remove all services or selected services
    Down {
        /// Stop only selected services, comma-separated or repeated
        #[arg(short, long, value_delimiter = ',')]
        services: Vec<String>,
    },

    /// Show status of managed containers
    Status,

    /// Show logs of one service
    Logs {
        /// Service key, e.g. rust-hello
        service: String,

        /// Follow logs
        #[arg(short, long, default_value_t = false)]
        follow: bool,
    },

    /// Print all available services
    List,
}

fn main() -> Result<()> {
    let cli = Cli::parse();

    ensure_docker_exists()?;

    let services = all_services();
    let index = build_index(&services);

    match cli.command {
        Commands::Up {
            services,
            force_recreate,
        } => {
            let selected = select_services(&index, &services)?;
            for svc in selected {
                up_service(svc, force_recreate)?;
            }
        }
        Commands::Down { services } => {
            let selected = select_services(&index, &services)?;
            for svc in selected {
                down_service(svc)?;
            }
        }
        Commands::Status => {
            status_services(&services)?;
        }
        Commands::Logs { service, follow } => {
            let svc = index
                .get(service.as_str())
                .copied()
                .ok_or_else(|| anyhow!("unknown service: {}", service))?;
            logs_service(svc, follow)?;
        }
        Commands::List => {
            for svc in &services {
                println!("{:<30} -> {}", svc.key, svc.image);
            }
        }
    }

    Ok(())
}

fn all_services() -> Vec<ServiceConfig> {
    vec![
        ServiceConfig {
            key: "java-spring-boot-maven-hello",
            container_name: "java-spring-boot-maven-hello",
            image: "java-spring-boot-maven-hello",
            ports: vec![pm("3001", "8080")],
            envs: vec![
                ("SERVICE_NAME", "my-service"),
                ("SERVICE_ENV", "staging"),
                ("LOG_LEVEL", "DEBUG"),
            ],
        },
        ServiceConfig {
            key: "java-spring-boot-gradle-hello",
            container_name: "java-spring-boot-gradle-hello",
            image: "java-spring-boot-gradle-hello",
            ports: vec![pm("3002", "8080")],
            envs: vec![
                ("SERVICE_NAME", "loan-service"),
                ("SERVICE_ENV", "production"),
                ("LOG_LEVEL", "INFO"),
            ],
        },
        ServiceConfig {
            key: "java-quarkus-hello",
            container_name: "java-quarkus-hello",
            image: "java-quarkus-hello",
            ports: vec![pm("3003", "8080")],
            envs: vec![
                ("SERVICE_NAME", "loan-service"),
                ("SERVICE_ENV", "production"),
                ("LOG_LEVEL", "INFO"),
            ],
        },
        ServiceConfig {
            key: "js-hello",
            container_name: "js-hello",
            image: "js-hello",
            ports: vec![pm("3004", "8080")],
            envs: vec![("PORT", "8080"), ("LOG_LEVEL", "debug")],
        },
        ServiceConfig {
            key: "php-hello",
            container_name: "php-hello",
            image: "php-hello",
            ports: vec![pm("3005", "8080"), pm("3006", "9500")],
            envs: vec![("PORT", "8080"), ("LOG_LEVEL", "debug")],
        },
        ServiceConfig {
            key: "go-hello",
            container_name: "go-hello",
            image: "go-hello",
            ports: vec![pm("3007", "3000")],
            envs: vec![
                ("SERVICE_NAME", "my-service"),
                ("SERVICE_ENV", "staging"),
                ("LOG_LEVEL", "debug"),
            ],
        },
        ServiceConfig {
            key: "dart-hello",
            container_name: "dart-hello",
            image: "dart-hello",
            ports: vec![pm("3008", "8080"), pm("3009", "8081"), pm("3010", "8082")],
            envs: vec![
                ("SERVICE_NAME", "my-service"),
                ("SERVICE_ENV", "staging"),
                ("LOG_LEVEL", "debug"),
            ],
        },
        ServiceConfig {
            key: "python-hello",
            container_name: "python-hello",
            image: "python-hello",
            ports: vec![pm("3011", "9000")],
            envs: vec![("PORT", "9000"), ("LOG_LEVEL", "debug")],
        },
        ServiceConfig {
            key: "csharp-hello",
            container_name: "csharp-hello",
            image: "csharp-hello",
            ports: vec![pm("3012", "9090")],
            envs: vec![("PORT", "9090"), ("LOG_LEVEL", "Debug")],
        },
        ServiceConfig {
            key: "bash-hello",
            container_name: "bash-hello",
            image: "bash-hello",
            ports: vec![pm("3013", "3000")],
            envs: vec![
                ("SERVICE_NAME", "loan-service"),
                ("SERVICE_ENV", "production"),
                ("LOG_LEVEL", "info"),
            ],
        },
        ServiceConfig {
            key: "rust-hello",
            container_name: "rust-hello",
            image: "rust-hello",
            ports: vec![pm("3014", "8080")],
            envs: vec![("PORT", "8080"), ("RUST_LOG", "debug")],
        },
        ServiceConfig {
            key: "kotlin-spring-boot-hello",
            container_name: "kotlin-spring-boot-hello",
            image: "kotlin-spring-boot-hello",
            ports: vec![pm("3015", "9090")],
            envs: vec![("PORT", "9090"), ("LOG_LEVEL", "DEBUG")],
        },
        ServiceConfig {
            key: "scala-hello",
            container_name: "scala-hello",
            image: "scala-hello",
            ports: vec![pm("3016", "3000")],
            envs: vec![("PORT", "3000"), ("LOG_LEVEL", "DEBUG")],
        },
        ServiceConfig {
            key: "lua-hello",
            container_name: "lua-hello",
            image: "lua-hello",
            ports: vec![pm("3017", "9090")],
            envs: vec![("PORT", "9090"), ("SERVICE_NAME", "my-service")],
        },
    ]
}

fn pm(host: &'static str, container: &'static str) -> PortMap {
    PortMap { host, container }
}

fn build_index<'a>(services: &'a [ServiceConfig]) -> BTreeMap<&'a str, &'a ServiceConfig> {
    services.iter().map(|s| (s.key, s)).collect()
}

fn select_services<'a>(
    index: &'a BTreeMap<&str, &'a ServiceConfig>,
    selected: &[String],
) -> Result<Vec<&'a ServiceConfig>> {
    if selected.is_empty() {
        return Ok(index.values().copied().collect());
    }

    let mut seen = HashSet::new();
    let mut result = Vec::new();

    for name in selected {
        let svc = index
            .get(name.as_str())
            .copied()
            .ok_or_else(|| anyhow!("unknown service: {}", name))?;
        if seen.insert(svc.key) {
            result.push(svc);
        }
    }

    Ok(result)
}

fn ensure_docker_exists() -> Result<()> {
    let status = Command::new("docker")
        .arg("--version")
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .context("failed to execute docker --version")?;

    if !status.success() {
        return Err(anyhow!("docker CLI is not available in PATH"));
    }

    Ok(())
}

fn up_service(svc: &ServiceConfig, force_recreate: bool) -> Result<()> {
    if container_exists(svc.container_name)? {
        if force_recreate {
            println!("recreating {}", svc.key);
            remove_container_force(svc.container_name)?;
        } else {
            println!("{} already exists, skipping", svc.key);
            return Ok(());
        }
    }

    println!("starting {}", svc.key);

    let mut cmd = Command::new("docker");
    cmd.arg("run")
        .arg("-d")
        .arg("--name")
        .arg(svc.container_name);

    for port in &svc.ports {
        cmd.arg("-p")
            .arg(format!("{}:{}", port.host, port.container));
    }

    for (k, v) in &svc.envs {
        cmd.arg("-e").arg(format!("{}={}", k, v));
    }

    cmd.arg(svc.image);

    let status = cmd.status().with_context(|| format!("failed to run {}", svc.key))?;
    if !status.success() {
        return Err(anyhow!("docker run failed for {}", svc.key));
    }

    Ok(())
}

fn down_service(svc: &ServiceConfig) -> Result<()> {
    if !container_exists(svc.container_name)? {
        println!("{} does not exist, skipping", svc.key);
        return Ok(());
    }

    println!("stopping/removing {}", svc.key);
    remove_container_force(svc.container_name)?;
    Ok(())
}

fn status_services(services: &[ServiceConfig]) -> Result<()> {
    for svc in services {
        let output = Command::new("docker")
            .args([
                "ps",
                "-a",
                "--filter",
                &format!("name=^{}$", svc.container_name),
                "--format",
                "{{.Names}}\t{{.Status}}\t{{.Ports}}",
            ])
            .output()
            .with_context(|| format!("failed to query status for {}", svc.key))?;

        let text = String::from_utf8_lossy(&output.stdout);
        if text.trim().is_empty() {
            println!("{:<30} -> not created", svc.key);
        } else {
            println!("{:<30} -> {}", svc.key, text.trim());
        }
    }

    Ok(())
}

fn logs_service(svc: &ServiceConfig, follow: bool) -> Result<()> {
    let mut cmd = Command::new("docker");
    cmd.arg("logs");
    if follow {
        cmd.arg("-f");
    }
    cmd.arg(svc.container_name);

    let status = cmd
        .status()
        .with_context(|| format!("failed to show logs for {}", svc.key))?;

    if !status.success() {
        return Err(anyhow!("docker logs failed for {}", svc.key));
    }

    Ok(())
}

fn container_exists(name: &str) -> Result<bool> {
    let output = Command::new("docker")
        .args([
            "ps",
            "-a",
            "--filter",
            &format!("name=^{}$", name),
            "--format",
            "{{.Names}}",
        ])
        .output()
        .with_context(|| format!("failed to inspect container {}", name))?;

    let text = String::from_utf8_lossy(&output.stdout);
    Ok(text.lines().any(|line| line.trim() == name))
}

fn remove_container_force(name: &str) -> Result<()> {
    let status = Command::new("docker")
        .args(["rm", "-f", name])
        .status()
        .with_context(|| format!("failed to remove container {}", name))?;

    if !status.success() {
        return Err(anyhow!("docker rm -f failed for {}", name));
    }

    Ok(())
}