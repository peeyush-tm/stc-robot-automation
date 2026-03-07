"""API environment configuration (endpoints, credentials)."""

API_ENVIRONMENTS = {
    "dev": {
        "BASE_URL": "https://marketlinq.airlinq.com",
        "AUTH_ENDPOINT": "/orchestration/api/auth/v1/access-token",
        "SUBSCRIBER_ENDPOINT": "/orchestration/carrierInboundGateway/v1/subscribers",
        "AUTH_USERNAME": "ford_service1",
        "AUTH_PASSWORD": "FordService@2025!",
        "AUTH_API_KEY": "",
        "RETURN_URL": "http://wiremock-service:8081",
        "ONBOARD_BAN": "",
        "ONBOARD_DEVICE_ID": "",
        "SUBSCRIBER_ID": "",
        "ONBOARD_REQUEST_ID": "",
    },
}


def get_variables(ENV="dev"):
    env = API_ENVIRONMENTS.get(ENV, API_ENVIRONMENTS["dev"])
    return env
