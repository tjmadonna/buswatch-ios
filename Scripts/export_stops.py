import argparse
import json
import os
import csv
from itertools import groupby
from dataclasses import dataclass

from normalize import normalized_routes, normalized_str


@dataclass
class Stop:
    id: str
    title: str
    latitude: float
    longitude: float
    routes: list


def load_trips(datapath: str) -> dict:
    """Load trips from thee csv file

    Args:
        datapath (str): directory with the trips.txt file

    Returns:
        dict: route id indexed by the cooresponding trip id
    """
    trips_path = os.path.join(datapath, "trips.txt")
    with open(trips_path) as trips_file:
        return {t["trip_id"]: t["route_id"] for t in csv.DictReader(trips_file)}


def load_stop_time(datapath: str) -> dict:
    st_path = os.path.join(datapath, "stop_times.txt")
    with open(st_path) as st_file:
        sorted_st = sorted(csv.DictReader(st_file), key=lambda st: st["stop_id"])
        return {
            key: [v["trip_id"] for v in value]
            for key, value in groupby(sorted_st, key=lambda st: st["stop_id"])
        }


def load_stops(datapath: str, trips: dict, stop_times: dict):
    stops_path = os.path.join(datapath, "stops.txt")
    with open(stops_path) as stops_file:
        stops = csv.DictReader(stops_file)
        return [
            Stop(
                id=s["stop_code"],
                title=normalized_str(s["stop_name"]),
                latitude=float(s["stop_lat"].strip()),
                longitude=float(s["stop_lon"].strip()),
                routes=normalized_routes(
                    [trips[trip_id] for trip_id in stop_times.get(s["stop_id"])]
                ),
            )
            for s in stops
            if s.get("stop_id") in stop_times
        ]


def save_stops(stops: list, savepath: str):
    if not savepath.endswith(".json"):
        savepath = os.path.join(savepath, "stops.json")
    with open(savepath, "w") as stops_file:
        json.dump([s.__dict__ for s in stops], stops_file, separators=(",", ":"))


def run(datapath: str, savepath: str):
    trips = load_trips(datapath)
    stop_times = load_stop_time(datapath)
    stops = load_stops(datapath, trips, stop_times)
    del trips
    del stop_times
    save_stops(stops, savepath)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="export stops to json and sqlite")
    parser.add_argument(
        "-d",
        "--datadir",
        default=".",
        help="directory containing the csv files",
    )
    parser.add_argument(
        "-o",
        "--outputdir",
        default="./stops.json",
        help="directory where output files are saved",
    )
    args = parser.parse_args()
    run(datapath=args.datadir, savepath=args.outputdir)
