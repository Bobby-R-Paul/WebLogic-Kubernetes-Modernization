FROM alpine:3.19

# 1. Install unzip for the WDT tool extraction
RUN apk add --no-cache unzip

# 2. Setup target structures including the WDT system lib path
RUN mkdir -p /auxiliary/models /auxiliary/weblogic-deploy/lib && \
    chown -R 1000:0 /auxiliary && chmod -R g+rwX /auxiliary

USER 1000

# 3. Copy and extract WDT binaries into the proper installation home
COPY --chown=1000:0 weblogic-deploy.zip /tmp/
RUN unzip /tmp/weblogic-deploy.zip -d /tmp/wdt-tmp && \
    mv /tmp/wdt-tmp/weblogic-deploy/* /auxiliary/weblogic-deploy/ && \
    rm -rf /tmp/weblogic-deploy.zip /tmp/wdt-tmp

# 4. Inject the MySQL Driver directly into the WDT System Classpath folder
COPY --chown=1000:0 mysql-connector-j-8.4.0.jar /auxiliary/weblogic-deploy/lib/

# 5. Copy the model file and the archive ZIP directly to the sourceModelHome root
COPY --chown=1000:0 wdt-models/model.yaml /auxiliary/models/
COPY --chown=1000:0 archive.zip /auxiliary/models/

