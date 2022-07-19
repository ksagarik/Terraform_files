variable "rgname" {
  type        = string
  description = "used for naming the resource group"
}

variable "rglocation"{
    type = string
    description = "used for selecting the location"
    default = "Central India"
}

variable "prefix"{
    type = string
    description = "used to define a standard prefix"
}

variable "vnet_cidr_prefix"{
    type = string
    description = "used to define a standard vnet prefix"
}

variable "subnet_cidr_prefix"{
    type = string
    description = "used to define a standard subnet prefix"
}