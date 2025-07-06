
# 📊 Monitoring Setup with Prometheus, Node Exporter & Grafana

This guide documents the monitoring stack implemented in the **Enterprise Infrastructure Automation on AWS** project.

---

## 🔧 Tools Used

- **Prometheus**: Metrics collector and time-series database  
- **Node Exporter**: Host-level metrics exporter for Prometheus  
- **Grafana**: Visualization dashboard to analyze Prometheus metrics  

---

## 🛠️ Installation Steps

### ✅ Prometheus Setup

1. **Create Prometheus user and directories**
   ```bash
   useradd --no-create-home --shell /bin/false prometheus
   mkdir /etc/prometheus /var/lib/prometheus
   chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
   ```

2. **Download Prometheus**
   ```bash
   cd /tmp
   wget https://github.com/prometheus/prometheus/releases/download/v2.51.2/prometheus-2.51.2.linux-amd64.tar.gz
   tar xvf prometheus-2.51.2.linux-amd64.tar.gz
   ```

3. **Install Prometheus binaries**
   ```bash
   cp prometheus-2.51.2.linux-amd64/prometheus /usr/local/bin/
   cp prometheus-2.51.2.linux-amd64/promtool /usr/local/bin/
   chown prometheus:prometheus /usr/local/bin/prometheus /usr/local/bin/promtool
   ```

4. **Copy consoles**
   ```bash
   cp -r prometheus-2.51.2.linux-amd64/consoles /etc/prometheus
   cp -r prometheus-2.51.2.linux-amd64/console_libraries /etc/prometheus
   chown -R prometheus:prometheus /etc/prometheus
   ```

5. **Configure `prometheus.yml`**
   ```yaml
   global:
     scrape_interval: 15s

   scrape_configs:
     - job_name: 'node-app'
       static_configs:
         - targets: ['localhost:3000']
     - job_name: 'node_exporter'
       static_configs:
         - targets: ['localhost:9100']
   ```

6. **Create Prometheus systemd service**
   ```ini
   [Unit]
   Description=Prometheus
   After=network.target

   [Service]
   User=prometheus
   ExecStart=/usr/local/bin/prometheus \
     --config.file=/etc/prometheus/prometheus.yml \
     --storage.tsdb.path=/var/lib/prometheus \
     --web.console.templates=/etc/prometheus/consoles \
     --web.console.libraries=/etc/prometheus/console_libraries
   Restart=on-failure

   [Install]
   WantedBy=multi-user.target
   ```

7. **Start Prometheus**
   ```bash
   systemctl daemon-reload
   systemctl enable prometheus
   systemctl start prometheus
   ```

---

### ✅ Node Exporter Setup

1. **Download Node Exporter**
   ```bash
   cd /tmp
   wget https://github.com/prometheus/node_exporter/releases/download/v1.8.1/node_exporter-1.8.1.linux-amd64.tar.gz
   tar xvf node_exporter-1.8.1.linux-amd64.tar.gz
   cp node_exporter-1.8.1.linux-amd64/node_exporter /usr/local/bin/
   ```

2. **Create systemd service**
   ```ini
   [Unit]
   Description=Node Exporter
   After=network.target

   [Service]
   ExecStart=/usr/local/bin/node_exporter

   [Install]
   WantedBy=multi-user.target
   ```

3. **Start Node Exporter**
   ```bash
   systemctl daemon-reload
   systemctl enable node_exporter
   systemctl start node_exporter
   ```

---

### ✅ Grafana Setup

1. **Add Grafana repo and install**
   ```bash
   sudo apt install -y software-properties-common apt-transport-https curl gpg
   sudo mkdir -p /etc/apt/keyrings
   curl -fsSL https://packages.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
   echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list > /dev/null
   sudo apt update
   sudo apt install grafana -y
   ```

2. **Start Grafana**
   ```bash
   sudo systemctl enable grafana-server
   sudo systemctl start grafana-server
   ```

3. **Access Grafana Dashboard**
   - URL: `http://<your-ec2-ip>:3000`
   - Default login:  
     - **Username**: `admin`  
     - **Password**: `admin`  

4. **Add Prometheus as a data source**
   - Navigate to `Configuration → Data Sources → Add Data Source`
   - Select **Prometheus** and use: `http://localhost:9090`

---

## 📈 Create Dashboards

- Use Grafana’s built-in dashboards or import community dashboards from [Grafana Dashboards](https://grafana.com/grafana/dashboards/)
- Common dashboards:
  - **Node Exporter Full**
  - **Docker Monitoring**
  - **EC2 Monitoring**

---

## 👨‍💻 Maintained by: [Sudarshan Gawande](https://sudarshangawande.com)

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?style=flat-square&logo=linkedin)](https://www.linkedin.com/in/sudarshan-gawande)
[![GitHub](https://img.shields.io/badge/GitHub-Repository-black?style=flat-square&logo=github)](https://github.com/sudarshan-gawande)

---

> *"Delivering secure, scalable, and monitored infrastructure with precision and automation."*
