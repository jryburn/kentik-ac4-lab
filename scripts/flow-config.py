import requests

# Kentik email, token, and API base URL
# Replace with your Kentik account email located at:
# https://portal.kentik.com/v4/profile/general
KENTIK_API_EMAIL = "user@domain.com"
# Replace with your Kentik API token located at:
# https://portal.kentik.com/v4/profile/auth
KENTIK_API_TOKEN = "mylongapitoken"
KENTIK_API_BASE_URL = "https://grpc.api.kentik.com/device/v202308beta1/device"


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


# Main function to loop through each device
# and then send batch update to Kentik
def main():
    # Update devices in Kentik with the IPs that will sending flow
    for device in devices:
        configure_device_in_kentik(device)


if __name__ == "__main__":
    main()
