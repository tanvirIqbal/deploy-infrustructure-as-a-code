provider "azurerm" {
  tenant_id = ""
  features {}
}

data "azurerm_resource_group" "main" {
  name = "${var.prefix}-rg"
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.0.0.0/24"]
  location            = var.location
  resource_group_name = data.azurerm_resource_group.main.name
  tags = {
    udacity = "udacity"
  }
}

resource "azurerm_subnet" "main" {
  name                 = "${var.prefix}-v=subnet"
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-nsg"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.main.name
  tags = {
    udacity = "udacity"
  }
}

resource "azurerm_network_security_rule" "AllowAccessToOtherVM" {
  name                        = "AllowAccessToOtherVM"
  priority                    = 310
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "10.0.0.0/24"
  destination_address_prefix  = "10.0.0.0/24"
  resource_group_name         = data.azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}
resource "azurerm_network_security_rule" "DenyAccessFromInterNet" {
  name                        = "DenyAccessFromInterNet"
  priority                    = 311
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-public-ip"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = var.location
  allocation_method   = "Static"
  tags = {
    udacity = "udacity"
  }
}

resource "azurerm_availability_set" "main" {
  name                = "${var.prefix}-aset"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.main.name
  tags = {
    udacity = "udacity"
  }
}

resource "azurerm_lb" "main" {
  name                = "${var.prefix}-lb"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.main.name
  tags = {
    udacity = "udacity"
  }
  frontend_ip_configuration {
    name                 = "${var.prefix}-lb-frontend"
    public_ip_address_id = azurerm_public_ip.main.id
  }
}

resource "azurerm_lb_backend_address_pool" "main" {
  loadbalancer_id = azurerm_lb.main.id
  resource_group_name = data.azurerm_resource_group.main.name
  name            = "${var.prefix}-backend-pool"
}

resource "azurerm_network_interface" "main" {
  count               = var.number_of_vms
  name                = "${var.prefix}-nic-${count.index}"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = var.location

  ip_configuration {
    name                          = "${var.prefix}-ipconfig"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = {
    udacity = "udacity"
  }
}
data "azurerm_image" "packer-image" {
  name                = "${var.prefix}-image"
  resource_group_name = data.azurerm_resource_group.main.name
}
resource "azurerm_linux_virtual_machine" "main" {
  count                           = var.number_of_vms
  name                            = "${var.prefix}-vm-${count.index}"
  resource_group_name             = data.azurerm_resource_group.main.name
  location                        = var.location
  size                            = "Standard_D2s_v3"
  admin_username                  = "${var.username}"
  admin_password                  = "${var.password}"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.main.*.id[count.index],
  ]
  availability_set_id             = azurerm_availability_set.main.id
  source_image_id                 = data.azurerm_image.packer-image.id

  os_disk {
    name                 = "${var.prefix}-osdisk-${count.index}"
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
  tags = {
    udacity = "udacity"
  }
}


