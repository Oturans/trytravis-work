FROM grafana/grafana:6.7.4
ADD datasource.yml /etc/grafana/provisioning/datasources/
ADD dashboards.yml /etc/grafana/provisioning/dashboards/
ADD dashboards/*.json /var/lib/grafana/dashboards/
