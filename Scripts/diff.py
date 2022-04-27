from typing import TypeVar, List
from dataclasses import dataclass
from json import dump
from argparse import ArgumentParser

from create_db import create_connection

T = TypeVar("T")


@dataclass
class Stop:
    id: str
    title: str
    latitude: float
    longitude: float
    routes: str
    service_type: int = 0


@dataclass
class Route:
    id: str
    title: str
    color: str


@dataclass
class StopRoute:
    stops: List[Stop]
    routes: List[Route]


@dataclass
class Changes:
    inserted: List[T]
    deleted: List[T]
    updated: List[T]


def fetch_items(db: str) -> StopRoute:
    conn = create_connection(db)

    c = conn.execute("SELECT * FROM stops")
    col_names = set([description[0] for description in c.description])

    cur = conn.cursor()
    if "service_type" in col_names:
        query = "SELECT id, title, latitude, longitude, routes, service_type FROM stops"
    else:
        query = "SELECT id, title, latitude, longitude, routes FROM stops"

    cur.execute(query)
    stops = [
        Stop(
            id=row[0],
            title=row[1],
            latitude=row[2],
            longitude=row[3],
            routes=row[4],
            service_type=row[5] if len(row) > 5 else 0,
        )
        for row in cur.fetchall()
    ]

    cur.execute("SELECT id, title, color FROM routes")
    routes = [Route(id=row[0], title=row[1], color=row[2]) for row in cur.fetchall()]

    return StopRoute(stops=stops, routes=routes)


def detect_changes(old_list: List[T], new_list: List[T]) -> Changes:
    old_dict = {item.id: item for item in old_list}

    inserted = list()
    deleted = old_dict
    updated = list()

    # Assume all items are deleted. Remove item from deleted if item is found in new list
    for item in new_list:
        if item.id in old_dict.keys():
            # Items has stayed the same or updated
            if item != old_dict[item.id]:
                # Item has been updated
                updated.append(item)
            del deleted[item.id]
        else:
            # Item has been inserted
            inserted.append(item)

    deleted_ids = [d.id for d in deleted.values()]

    return Changes(inserted=inserted, deleted=deleted_ids, updated=updated)


def detect(db_old: str, db_new: str) -> dict:
    stoproute_old = fetch_items(db_old)
    stoproute_new = fetch_items(db_new)

    stop_changes = detect_changes(
        old_list=stoproute_old.stops, new_list=stoproute_new.stops
    )
    route_changes = detect_changes(
        old_list=stoproute_old.routes, new_list=stoproute_new.routes
    )

    return {"stops": stop_changes, "routes": route_changes}


def run(db_old: str, db_new: str, output: str):
    changes = detect(db_old, db_new)
    with open(output, "w") as changes_file:
        dump(changes, changes_file, separators=(",", ":"), default=vars)


if __name__ == "__main__":
    parser = ArgumentParser(
        description="determine the differences between two versions of the buswatch database"
    )
    parser.add_argument(
        "-old",
        help="older version of the database",
    )
    parser.add_argument(
        "-new",
        help="newer version of the database",
    )
    parser.add_argument(
        "-o",
        "--out",
        help="output json file",
    )

    args = parser.parse_args()
    run(db_old=args.old, db_new=args.new, output=args.out)
