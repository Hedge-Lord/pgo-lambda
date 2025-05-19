# ---------- build stage ----------
FROM --platform=linux/amd64 public.ecr.aws/amazonlinux/amazonlinux:2023.7.20250512.0 AS build

RUN dnf -y install maven zip tar gzip shadow-utils \
    && useradd -M -u 10001 javauser

# Grab GraalVM JDK 21 CE (full JDK with JFR & native‑image)
ARG GRAAL_URL=https://download.oracle.com/graalvm/21/latest/graalvm-jdk-21_linux-x64_bin.tar.gz
RUN curl -sL $GRAAL_URL | tar zx -C /opt
ENV GRAAL_HOME=/opt/graalvm-jdk-21.0.7+8.1 \
    JAVA_HOME=/opt/graalvm-jdk-21.0.7+8.1 \
    PATH="/opt/graalvm-jdk-21.0.7+8.1/bin:$PATH"

WORKDIR /function
COPY pom.xml .
RUN mvn -q dependency:go-offline
COPY src ./src
RUN mvn -q package -DskipTests
# fat jar at target/app.jar

# ---------- runtime stage ----------
FROM --platform=linux/amd64 public.ecr.aws/lambda/provided:al2023

# copy over graalvm from build stage
COPY --from=build /opt/graalvm-jdk-21.0.7+8.1 /opt/graalvm
ENV JAVA_HOME=/opt/graalvm
ENV PATH="$JAVA_HOME/bin:$PATH"

# copy over app jar and dependencies
COPY --from=build /function/target/app.jar /var/task/app.jar
COPY --from=build /function/target/dependency/* /var/task/

# optionally copy the user setup from builder
COPY --from=build /etc/passwd /etc/passwd
COPY --from=build /etc/group  /etc/group

# USER 10001  # maps to javauser from builder

# enable JFR
ENV JAVA_TOOL_OPTIONS="-XX:StartFlightRecording=filename=/tmp/flight.jfr,settings=profile,dumponexit=true,maxsize=100M,maxage=30m"

# Use the AWS Lambda Runtime Interface Client with the correct Java path
ENTRYPOINT [ "/opt/graalvm/bin/java", "-cp", "/var/task/*", "com.amazonaws.services.lambda.runtime.api.client.AWSLambda" ]
CMD [ "com.example.Handler::handleRequest" ]
    