# ---------- build stage ----------
    FROM public.ecr.aws/amazonlinux/2023 AS build

    # Grab GraalVM JDK 21 CE (full JDK with JFR & native‑image)
    ARG GRAAL_URL=https://download.oracle.com/graalvm/21/latest/graalvm-jdk-21_linux-x64_bin.tar.gz
    RUN curl -sL $GRAAL_URL | tar zx -C /opt
    ENV GRAAL_HOME=/opt/graalvm-jdk-21
    ENV PATH="$GRAAL_HOME/bin:$PATH"
    
    # build toolchain
    RUN dnf -y install maven zip
    
    WORKDIR /function
    COPY pom.xml .
    RUN mvn -q dependency:go-offline
    COPY src ./src
    RUN mvn -q package -DskipTests
    # fat jar at target/app.jar
    
    # ---------- runtime stage ----------
    FROM public.ecr.aws/lambda/provided:al2023
    
    # minimal libs for JVM
    RUN yum -y install shadow-utils glibc-langpack-en && yum clean all \
     && useradd -M -u 10001 javauser
    
    # copy GraalVM JDK (≈ 300 MB) and strip extraneous bits
    COPY --from=build /opt/graalvm-jdk-21 /opt/graalvm
    ENV JAVA_HOME=/opt/graalvm
    ENV PATH="$JAVA_HOME/bin:$PATH"
    
    # copy Lambda bits
    COPY --from=build /function/target/app.jar     /var/task/app.jar
    COPY docker/bootstrap                          /var/runtime/bootstrap
    RUN chmod +x /var/runtime/bootstrap && chown -R javauser /var/task
    
    USER javauser
    # Continuous flight recording, dump on JVM exit
    ENV JAVA_TOOL_OPTIONS="-XX:StartFlightRecording=filename=/tmp/flight.jfr,settings=profile,dumponexit=true,maxsize=100M,maxage=30m"
    CMD ["java","-jar","/var/task/app.jar"]
    