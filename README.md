HCI PSCAN Keeper
================
These scripts work around the PSCAN state problem with Bluetooth HCI devices on some Linux machines.

Observed on some machines, though the state of a Bluetooth HCI device is set to "UP RUNNING PSCAN" at start-up, it is changed to "UP RUNNING" when the Bluetooth adapter connects or is connected to another Bluetooth device. This problem is found on:

  * Hardware platform: Raspberry Pi Model B
  * Operating system: Raspbian / Linux 3.18.11+
  * Bluetooth daemon: BlueZ 4.99
  * Bluetooth adapter: CSR Bluetooth Dongle (HCI mode) / USB 0a12:0001

This keeper will periodically call `hciconfig` to scan all HCI devices for their states, and reset the PSCAN state for those who have lost it.

Installation
------------
Copy the ruby script to `/home` and copy the executatble to `/etc/init.d`.

If you would like the daemon to start automatically, configure it as you usually do with a Linux service, i.e. `update-rc.d hci_pscan_daemon defaults`.

