FROM alpine:latest
RUN apk add --no-cache curl bash unzip ca-certificates openssl && \
    curl -L -s https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip -o /tmp/xray.zip && \
    unzip -q /tmp/xray.zip xray -d /usr/local/bin/ && \
    rm -f /tmp/xray.zip && \
    chmod +x /usr/local/bin/xray


RUN mkdir -p /etc/xray


RUN cat > /etc/xray/config.json << 'EOF'
{
  "log": { "loglevel": "warning" },
  "inbounds": [{
    "port": 443,
    "protocol": "trojan",
    "settings": {
      "clients": [{
        "password": "zxczxc123",
        "email": "user@example.com"
      }],
      "fallbacks": [{
        "dest": "www.google.com:80"
      }]
    },
    "streamSettings": {
      "network": "tcp",
      "security": "tls",
      "tlsSettings": {
        "certificates": [{
          "certificateFile": "/etc/xray/ssl.crt",
          "keyFile": "/etc/xray/ssl.key"
        }]
      }
    }
  }],
  "outbounds": [{
    "protocol": "freedom"
  }]
}
EOF


RUN openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost" \
    -keyout /etc/xray/ssl.key -out /etc/xray/ssl.crt 2>/dev/null

EXPOSE 443


CMD ["xray", "run", "-config=/etc/xray/config.json"]