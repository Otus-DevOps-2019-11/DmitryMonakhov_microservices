variable project {
  description = "docker-267016"
}
variable region {
  description = "Region"
  # Значение по умолчанию
  default = "europe-west1"
}
variable zone {
  description = "Zone"
  # Значение по умолчанию
  default = "europe-west1-b"
}
variable public_key_path {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}
variable private_key_path {
  # Описание переменной
  description = "Path to the private key used for ssh access"
}
variable disk_image {
  description = "Disk image"
  default     = "reddit-docker-host"
}
variable node_count {
  description = "number of nodes"
  default     = "1"
}
