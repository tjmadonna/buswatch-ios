import argparse
import json
import os

import requests

from normalize import normalized_str


def load_routes(api_key: str):
    returnList = []
    for t in ["Port%20Authority%20Bus", "Light%20Rail"]:
        url = f"https://truetime.portauthority.org/bustime/api/v3/getroutes?key={api_key}&format=json&rtpidatafeed={t}"
        res = requests.get(url)
        bt_res = res.json()["bustime-response"]
        returnList.extend(
            [
                {
                    "id": route["rt"],
                    "title": normalized_str(route["rtnm"]),
                    "color": route["rtclr"],
                }
                for route in bt_res["routes"]
            ]
        )
    return returnList


def save_routes(routes: list, savepath: str):
    if not savepath.endswith(".json"):
        savepath = os.path.join(savepath, "routes.json")
    with open(savepath, "w") as routes_file:
        json.dump(routes, routes_file, separators=(",", ":"))


def run(savepath: str, api_key: str):
    routes = load_routes(api_key)
    save_routes(routes, savepath)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="export routes to json")
    parser.add_argument(
        "-k",
        "--key",
        help="api key for the truetime service",
    )
    parser.add_argument(
        "-o",
        "--outputdir",
        default="./routes.json",
        help="directory where output files are saved",
    )
    args = parser.parse_args()
    run(savepath=args.outputdir, api_key=args.key)
