# EC2 Instance with Monitoring & Docker App Deployment
# Maintained by: Sudarshan Gawande
# Portfolio     : https://sudarshangawande.com
# GitHub        : https://github.com/sudarshan-gawande
# LinkedIn      : https://www.linkedin.com/in/sudarshangawande

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  description = "Allow web, SSH, and monitoring access"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "ec2-sg"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Owner       = "Sudarshan Gawande"
  }
}

resource "aws_instance" "app" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    apt update -y

    # Install Docker
    apt install docker.io -y
    systemctl start docker
    systemctl enable docker
    sudo usermod -aG docker ubuntu
    newgrp docker

    # Deploy Node.js App
    echo "${var.dockerhub_password}" | docker login -u ${var.dockerhub_username} --password-stdin
    docker pull ${var.dockerhub_username}/infra-app:latest
    docker run -d -p 80:3000 --name node-app ${var.dockerhub_username}/infra-app:latest

    # Install Prometheus
    useradd --no-create-home --shell /bin/false prometheus
    mkdir /etc/prometheus /var/lib/prometheus
    chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
    cd /tmp
    wget https://github.com/prometheus/prometheus/releases/download/v2.51.2/prometheus-2.51.2.linux-amd64.tar.gz
    tar xvf prometheus-2.51.2.linux-amd64.tar.gz
    cp prometheus-2.51.2.linux-amd64/prometheus /usr/local/bin/
    cp prometheus-2.51.2.linux-amd64/promtool /usr/local/bin/
    chown prometheus:prometheus /usr/local/bin/prometheus /usr/local/bin/promtool
    cp -r prometheus-2.51.2.linux-amd64/consoles /etc/prometheus
    cp -r prometheus-2.51.2.linux-amd64/console_libraries /etc/prometheus
    chown -R prometheus:prometheus /etc/prometheus

    cat <<PROMEOF > /etc/prometheus/prometheus.yml
    global:
      scrape_interval: 15s

    scrape_configs:
      - job_name: 'node-app'
        static_configs:
          - targets: ['localhost:3000']
      - job_name: 'node_exporter'
        static_configs:
          - targets: ['localhost:9100']
    PROMEOF

    chown prometheus:prometheus /etc/prometheus/prometheus.yml

    cat <<SERVICEEOF > /etc/systemd/system/prometheus.service
    [Unit]
    Description=Prometheus
    After=network.target

    [Service]
    User=prometheus
    Group=prometheus
    Type=simple
    ExecStart=/usr/local/bin/prometheus \\
      --config.file=/etc/prometheus/prometheus.yml \\
      --storage.tsdb.path=/var/lib/prometheus \\
      --web.console.templates=/etc/prometheus/consoles \\
      --web.console.libraries=/etc/prometheus/console_libraries
    Restart=on-failure

    [Install]
    WantedBy=multi-user.target
    SERVICEEOF

    systemctl daemon-reload
    systemctl enable prometheus
    systemctl start prometheus

    # Install Node Exporter
    cd /tmp
    wget https://github.com/prometheus/node_exporter/releases/download/v1.8.1/node_exporter-1.8.1.linux-amd64.tar.gz
    tar xvf node_exporter-1.8.1.linux-amd64.tar.gz
    cp node_exporter-1.8.1.linux-amd64/node_exporter /usr/local/bin/

    cat <<NODEEOF > /etc/systemd/system/node_exporter.service
    [Unit]
    Description=Node Exporter
    After=network.target

    [Service]
    ExecStart=/usr/local/bin/node_exporter

    [Install]
    WantedBy=multi-user.target
    NODEEOF

    systemctl daemon-reload
    systemctl enable node_exporter
    systemctl start node_exporter

    # Install Grafana
    sudo apt install -y software-properties-common apt-transport-https curl gpg
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://packages.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
    echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list > /dev/null
    sudo apt update -y
    sudo apt install grafana -y
    sudo systemctl enable grafana-server
    sudo systemctl start grafana-server
  EOF

  tags = {
    Name        = "DockerAppInstance"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Owner       = "Sudarshan Gawande"
  }
}

resource "aws_eip" "static_ip" {
  instance = aws_instance.app.id
  domain   = "vpc"
}