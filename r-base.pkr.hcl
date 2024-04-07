variable "cran_packages" {
    type = string
    description = "REQUIRED: space-separated list of CRAN package names to be installed"
    default = "<DEFINE ME!>"
}

local "r_library_xz" {
    expression = "${path.root}/r_library.${uuidv4()}.tar.xz"
}

build {
    source "source.docker.rhel9-ubi" {
        name = "install_cran_packages"
        discard = true
    }

    provisioner "shell" {
        inline = [
            "set -o xtrace errexit",
            "dnf --assumeyes --allowerasing upgrade",
            "dnf --assumeyes --allowerasing install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm",
            "dnf --assumeyes --allowerasing --enablerepo codeready-builder-for-rhel-9-$(arch)-rpms install R-base R-devel xz diffutils"
        ]
    }

    provisioner "shell" {
        inline_shebang = "/bin/bash -e"
        inline = [
            "for package in ${var.cran_packages} ; do",
                "R -e \"install.packages('$package', repos = 'https://cloud.r-project.org')\"",
            "done",
            "tar --create --xz --file /tmp/library.tar.xz /usr/lib64/R/library"
        ]
    }

    provisioner "file" {
        source = "/tmp/library.tar.xz"
        destination = "${local.r_library_xz}"
        direction = "download"
    }
}

build {
    source "source.docker.rhel9-ubi" {
        name = "build_base"
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
            "dnf --assumeyes --allowerasing install R-base xz"
        ]
    }

    provisioner "file" {
        source = "${local.r_library_xz}"
        destination = "/tmp/library.tar.xz"
        direction = "upload"
        generated = true
        pause_before = "30s"
        max_retries = 100
    }

    provisioner "shell" {
        inline = [
            "set -o xtrace errexit",
            "tar --extract --xz --file /tmp/library.tar.xz --directory /",
            "rm --force /tmp/rlibs.tar.xz"
        ]
    }

    post-processor "shell-local" {
        name = "remove_r_library_xz"
        inline = [
            "set -o xtrace errexit",
            "rm --force ${local.r_library_xz}"
        ]
    }
}