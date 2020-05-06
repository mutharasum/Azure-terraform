provider "azurerm" {
  version = "~>2.0"
  features {}
}
resource "azurerm_resource_group" "test" {
 name     = "test-trbhi"
 location = "West US 2"
 
}

resource "azurerm_virtual_network" "test" {
 name                = "test-trbhi-vnet"
 address_space       = ["10.0.0.0/16"]
 location            = azurerm_resource_group.test.location
 resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test-trbhi-subnet" {
 name                 = "acctsub"
 resource_group_name  = azurerm_resource_group.test.name
 virtual_network_name = azurerm_virtual_network.test.name
 address_prefix       = "10.0.2.0/24"
}


resource "azurerm_network_interface" "test" {
 count               = 2
 name                = "acctni${count.index}"
 location            = azurerm_resource_group.test.location
 resource_group_name = azurerm_resource_group.test.name

 ip_configuration {
   name                          = "testConfiguration"
   subnet_id                     = azurerm_subnet.test-trbhi-subnet.id
   private_ip_address_allocation = "dynamic"
 }
}

resource "azurerm_managed_disk" "test" {
 count                = 2
 name                 = "datadisk_existing_${count.index}"
 location             = azurerm_resource_group.test.location
 resource_group_name  = azurerm_resource_group.test.name
 storage_account_type = "Standard_LRS"
 create_option        = "Empty"
 disk_size_gb         = "1023"
}


resource "azurerm_virtual_machine" "test" {
 count                 = 2
 name                  = "test-trbhi${count.index}"
 location              = azurerm_resource_group.test.location
 resource_group_name   = azurerm_resource_group.test.name
 network_interface_ids = [element(azurerm_network_interface.test.*.id, count.index)]
 vm_size               = "Standard_DS1_v2"
 delete_os_disk_on_termination = true

 # Uncomment this line to delete the data disks automatically when deleting the VM
 # delete_data_disks_on_termination = true

 storage_image_reference {
   publisher = "Canonical"
   offer     = "UbuntuServer"
   sku       = "16.04-LTS"
   version   = "latest"
 }

 storage_os_disk {
   name              = "myosdisk${count.index}"
   caching           = "ReadWrite"
   create_option     = "FromImage"
   managed_disk_type = "Standard_LRS"
 }


 storage_data_disk {
   name            = element(azurerm_managed_disk.test.*.name, count.index)
   managed_disk_id = element(azurerm_managed_disk.test.*.id, count.index)
   create_option   = "Attach"
   lun             = 1
   disk_size_gb    = element(azurerm_managed_disk.test.*.disk_size_gb, count.index)
 }

 os_profile {
   computer_name  = "test-trbhi-muthu"
   admin_username = "muthu_arasu"
   admin_password = "Password1234!"
 }

 os_profile_linux_config {
   disable_password_authentication = false
 }

 tags = {
   environment = "staging"
 }
}
