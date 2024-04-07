build {
    source "source.docker.rhel9-ubi" {
        name = "build_minimal"
        commit = true
        changes = [
            "LABEL version=0.0.0 MAINTAINER=steven.conn@gmail.com",
            "ONBUILD RUN date",
            "ENTRYPOINT R"
        ]
    }

    provisioner "shell" {
        inline = [
            "set -o xtrace errexit",
            "dnf --assumeyes --allowerasing upgrade",
            "dnf --assumeyes --allowerasing install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm",
            "dnf --assumeyes --allowerasing install R-base"
        ]
    }
}