build {
    name = "build_full"

    source "source.docker.rhel9-ubi" {
        commit = true
    }

    provisioner "shell" {
        inline = [
            "set -o xtrace errexit",
            "dnf --assumeyes --allowerasing upgrade",
            "dnf --assumeyes --allowerasing install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm",
            "dnf --assumeyes --allowerasing install --enablerepo codeready-builder-for-rhel-9-$(arch)-rpms R-base R-devel diffutils xz"
        ]
    }
}