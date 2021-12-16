import requests

LOCAL_ENDPOINT = "http://localhost:7071/api/"


def test_hello():

    response = requests.get(f"{LOCAL_ENDPOINT}hello?name=tests")
    assert response.ok, "oopps response was not ok"
