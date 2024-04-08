variable "meta" {
    type = object({ release = string, r_release = string, maintainer = string })
}

source "docker" "rhel9-ubi" {
    image = "registry.access.redhat.com/ubi9/ubi:latest"
    pull = true
    changes = [
        "LABEL release=${var.meta.release}",
        "LABEL r_release=${var.meta.r_release}",
        "LABEL maintainer=${var.meta.maintainer}",
        "ONBUILD RUN date",
        "ENTRYPOINT R"
    ]
}