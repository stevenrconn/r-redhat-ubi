build {
    name = "build_minimal"

    source "source.docker.rhel9-ubi" {
        commit = true
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