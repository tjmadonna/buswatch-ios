import argparse
from dataclasses import dataclass
import sqlite3
import json
from typing import List, Optional

from export_stops import Stop

DB_VERSION = 5

RESOURCE_VERSION = 1


@dataclass
class Route:
    id: str
    title: str
    color: str


def create_connection(db_file: str) -> Optional[sqlite3.Connection]:
    # """create a database connection to the SQLite database
    #     specified by db_file
    # :param db_file: database file
    # :return: Connection object or None
    # """
    conn = None
    try:
        conn = sqlite3.connect(db_file)
        return conn
    except sqlite3.Error as e:
        print(e)

    return conn


def create_table(conn: sqlite3.Connection, create_table_sql: str):
    """create a table from the create_table_sql statement
    :param conn: Connection object
    :param create_table_sql: a CREATE TABLE statement
    :return:
    """
    try:
        conn.execute(create_table_sql)
    except sqlite3.Error as e:
        print(e)


def create_stops(conn: sqlite3.Connection, stops: List[Stop]):
    try:
        stop_tuples = [
            (s.id, s.title, s.latitude, s.longitude, ",".join(s.routes), s.service_type)
            for s in stops
        ]
        conn.executemany(
            "INSERT INTO stops (id, title, latitude, longitude, routes, service_type) values (?, ?, ?, ?, ?, ?);",
            stop_tuples,
        )
    except sqlite3.Error as e:
        print(e)


def create_routes(conn: sqlite3.Connection, routes: List[Route]):
    try:
        routes_tuples = [(r.id, r.title, r.color) for r in routes]
        conn.executemany(
            "INSERT INTO routes (id, title, color) values (?, ?, ?);",
            routes_tuples,
        )
    except sqlite3.Error as e:
        print(e)


def create_last_location(conn: sqlite3.Connection):
    try:
        loc_tuples = (
            1,
            40.44785576556447,
            40.4281598420304,
            -80.00565690773512,
            -79.98956365216942,
        )
        conn.execute(
            "INSERT INTO last_location (id, north, south, west, east) values (?, ?, ?, ?, ?);",
            loc_tuples,
        )
    except sqlite3.Error as e:
        print(e)


def create_migrations(conn: sqlite3.Connection):
    try:
        mig_tuples = [(i,) for i in range(1, DB_VERSION + 1)]
        conn.executemany(
            "INSERT INTO grdb_migrations (identifier) values (?);",
            mig_tuples,
        )
    except sqlite3.Error as e:
        print(e)


def create_resource_version(conn: sqlite3.Connection):
    try:
        res_tuples = [(i,) for i in range(1, RESOURCE_VERSION + 1)]
        conn.executemany(
            "INSERT INTO resource_versions (version) values (?);",
            res_tuples,
        )
    except sqlite3.Error as e:
        print(e)


def run(stopsfile: str, routesfile: str, outputfile: str):
    with open(stopsfile) as stops_file:
        stops = [Stop(**s) for s in json.load(stops_file)]
        filtered = [s for s in stops if s.service_type == 1]

    with open(routesfile) as routes_file:
        routes = [Route(**r) for r in json.load(routes_file)]

    if stops and routes:
        conn = create_connection(outputfile)

        # Migrations
        create_table(
            conn,
            """ CREATE TABLE grdb_migrations (
                identifier TEXT NOT NULL PRIMARY KEY
            );
            """,
        )

        # Routes
        create_table(
            conn,
            """ CREATE TABLE routes (
                id TEXT PRIMARY KEY,
                title TEXT NOT NULL,
                color TEXT NOT NULL
            );
            """,
        )

        # Stops
        create_table(
            conn,
            """ CREATE TABLE stops (
                id TEXT PRIMARY KEY,
                title TEXT NOT NULL,       
                favorite INTEGER NOT NULL DEFAULT 0,
                latitude REAL NOT NULL,
                longitude REAL NOT NULL,
                routes TEXT,
                excluded_routes TEXT,
                service_type INTEGER NOT NULL DEFAULT 0
            );
            """,
        )

        # Last Location
        create_table(
            conn,
            """ CREATE TABLE last_location (
                id INTEGER PRIMARY KEY,
                north DOUBLE NOT NULL,
                south DOUBLE NOT NULL,
                west DOUBLE NOT NULL,
                east DOUBLE NOT NULL
            );
            """,
        )

        # Resource version
        create_table(
            conn,
            """ CREATE TABLE resource_versions (
                version INTEGER PRIMARY KEY
            );
            """,
        )

        create_stops(conn, stops)
        create_routes(conn, routes)
        create_last_location(conn)
        create_migrations(conn)
        create_resource_version(conn)

        conn.commit()
        conn.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="json files into sqlite")
    parser.add_argument(
        "-s",
        "--stopsfile",
        default="./stops.json",
        help="path of the stops json file",
    )
    parser.add_argument(
        "-r",
        "--routesfile",
        default="./routes.json",
        help="path of the routes json file",
    )
    parser.add_argument(
        "-o",
        "--outputfile",
        default=f"./databasev{DB_VERSION}.db",
        help="path of the output sqlite file",
    )
    args = parser.parse_args()
    run(
        stopsfile=args.stopsfile, routesfile=args.routesfile, outputfile=args.outputfile
    )
