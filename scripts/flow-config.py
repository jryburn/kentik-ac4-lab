import requests
from pygnmi.client import gNMIclient

# Kentik email, token, and API base URL
# Replace with your Kentik account email located at:
# https://portal.kentik.com/v4/profile/general
KENTIK_API_EMAIL = "user@domain.com"
# Replace with your Kentik API token located at:
# https://portal.kentik.com/v4/profile/auth
KENTIK_API_TOKEN = "mylongapitoken"
KENTIK_API_BASE_URL = "https://grpc.api.kentik.com/device/v202308beta1/device"

# SR Linux device credentials
SRL_USERNAME = "admin"
SRL_PASSWORD = "NokiaSrl1!"

# gNMI connection settings
GNMI_PORT = 57401
INSECURE = True
SKIP_VERIFY = True

# List of devices to configure
devices = [
    {
        "ip": "172.20.20.11",
        "username": SRL_USERNAME,
        "password": SRL_PASSWORD,
        "kentik_device_name": "leaf1",
    },
    {
        "ip": "172.20.20.12",
        "username": SRL_USERNAME,
        "password": SRL_PASSWORD,
        "kentik_device_name": "leaf2",
    },
    {
        "ip": "172.20.20.13",
        "username": SRL_USERNAME,
        "password": SRL_PASSWORD,
        "kentik_device_name": "leaf3",
    },
    {
        "ip": "172.20.20.14",
        "username": SRL_USERNAME,
        "password": SRL_PASSWORD,
        "kentik_device_name": "leaf4",
    },
    {
        "ip": "172.20.20.15",
        "username": SRL_USERNAME,
        "password": SRL_PASSWORD,
        "kentik_device_name": "leaf5",
    },
    {
        "ip": "172.20.20.16",
        "username": SRL_USERNAME,
        "password": SRL_PASSWORD,
        "kentik_device_name": "leaf6",
    },
    {
        "ip": "172.20.20.17",
        "username": SRL_USERNAME,
        "password": SRL_PASSWORD,
        "kentik_device_name": "leaf7",
    },
    {
        "ip": "172.20.20.18",
        "username": SRL_USERNAME,
        "password": SRL_PASSWORD,
        "kentik_device_name": "leaf8",
    },
    {
        "ip": "172.20.20.21",
        "username": SRL_USERNAME,
        "password": SRL_PASSWORD,
        "kentik_device_name": "spine1",
    },
    {
        "ip": "172.20.20.22",
        "username": SRL_USERNAME,
        "password": SRL_PASSWORD,
        "kentik_device_name": "spine2",
    },
    # Add more devices as needed
]


# Function to get device_id from Kentik by device name
def get_device_id_from_kentik(device_name):
    headers = {
        'X-CH-Auth-Email': f"{KENTIK_API_EMAIL}",
        'X-CH-Auth-API-Token': f"{KENTIK_API_TOKEN}",
        'Content-Type': 'application/json',
    }

    # Retrieve the list of devices from Kentik
    try:
        response = requests.get(
            KENTIK_API_BASE_URL, headers=headers, timeout=10
        )
        response.raise_for_status()
        devices_list = response.json().get("devices", [])

        # Find the device ID for the given device name
        for device in devices_list:
            if device.get("deviceName") == device_name:
                return device.get("id")
        print(f"Device '{device_name}' not found in Kentik.")
    except requests.exceptions.RequestException as e:
        print(f"Failed to retrieve devices from Kentik: {e}")

    return None


# Function to send batch update to Kentik
def configure_device_in_kentik(device):
    # Retrieve the device_id if not already available
    if not device.get("device_id"):
        device_id = get_device_id_from_kentik(device["kentik_device_name"])
        if not device_id:
            msg = (f"Skipping Kentik configuration for "
                   f"{device['kentik_device_name']} due to missing device_id.")
            print(msg)
            return
        device["device_id"] = device_id

    headers = {
        'X-CH-Auth-Email': f"{KENTIK_API_EMAIL}",
        'X-CH-Auth-API-Token': f"{KENTIK_API_TOKEN}",
        'Content-Type': 'application/json',
    }

    # Kentik device payload for configuration
    device_name = device['kentik_device_name']
    payload = {
        "device": {
            "id": device["device_id"],
            "deviceName": device_name,
            "sendingIps": [device["ip"]],
            "planId": 12345,  # Replace with your Kentik plan ID
            "siteId": 12345,  # Replace with your Kentik site ID
            "deviceSampleRate": 512,
            "deviceDescription": f"{device_name} configured for sFlow"
        }
    }

    # Send device update request to Kentik
    url = f"{KENTIK_API_BASE_URL}/{device['device_id']}"
    try:
        response = requests.put(url, headers=headers, json=payload, timeout=10)
        response.raise_for_status()
        print(f"Device {device_name} updated in Kentik:")
    except requests.exceptions.RequestException as e:
        print(f"Failed to update device {device_name} in Kentik: {e}")


# Function to configure sFlow on the SR Linux switch using gNMI
def configure_sflow_on_switch(device):
    try:
        # gNMI path for sFlow configuration
        paths = [
            # Base path for sFlow configuration
            "/system/sflow",
            # Sample rate path
            "/system/sflow/sample-rate",
            # Collector configuration path
            "/system/sflow/collector",
            # Source interface path
            "/system/sflow/interface"
        ]

        # Connect to the SR Linux device
        with gNMIclient(
                target=(device["ip"], GNMI_PORT),
                username=device["username"],
                password=device["password"],
                insecure=INSECURE,
                skip_verify=SKIP_VERIFY
        ) as gnmi:
            # Configure sFlow
            updates = [
                # Enable sFlow
                (paths[0], {"admin-state": "enable"}),
                # Set sample rate
                (paths[1], {"rate": 512}),
                # Configure collector
                (paths[2], {
                    "collector-address": "172.20.20.1",
                    "network-instance": "mgmt",
                    "port": 9995
                }),
                # Set source interface to mgmt0
                (paths[3], {"name": "mgmt0"})
            ]

            # Apply configuration using gNMI SetRequest
            gnmi.set(update=updates)
            print(f"sFlow configuration applied to switch {device['ip']}.")
    except (gNMIclient.Error, ConnectionError) as e:
        print(f"Failed to configure sFlow on the switch {device['ip']}: {e}")


# Main function to loop through each device, configure sFlow,
# and then send batch update to Kentik
def main():
    # Step 1: Update devices in Kentik with the IPs that will sending flow
    for device in devices:
        configure_device_in_kentik(device)

    # Step 2: Configure sFlow on each switch
    for device in devices:
        print(f"Configuring device: {device['kentik_device_name']}")
        print(f"IP address: {device['ip']}")
        configure_sflow_on_switch(device)


if __name__ == "__main__":
    main()
