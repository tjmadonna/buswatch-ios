import argparse
import json
import os

import requests

from normalize import normalized_str


def load_routes():
    url = "https://truetime.portauthority.org/bustime/api/v3/getroutes?key=h75M7sFVMwxgdeTEaRWQk8eES&format=json&rtpidatafeed=Port%20Authority%20Bus"
    res = requests.get(url)
    bt_res = res.json()["bustime-response"]
    return [
        {
            "id": route["rt"],
            "title": normalized_str(route["rtnm"]),
            "color": route["rtclr"],
        }
        for route in bt_res["routes"]
    ]


def save_routes(routes: list, savepath: str):
    if not savepath.endswith(".json"):
        savepath = os.path.join(savepath, "routes.json")
    with open(savepath, "w") as routes_file:
        json.dump(routes, routes_file, separators=(",", ":"))


def run(savepath: str):
    routes = load_routes()
    save_routes(routes, savepath)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="export routes to json")
    parser.add_argument(
        "-o",
        "--outputdir",
        default="./routes.json",
        help="directory where output files are saved",
    )
    args = parser.parse_args()
    run(savepath=args.outputdir)
